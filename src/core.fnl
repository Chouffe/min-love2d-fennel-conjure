(local fennel (require :lib.fennel))
(local lume (require :lib.lume))
(local repl (require :lib.stdio))

(local canvas 
  (let [(w h) (love.window.getMode)]
    (love.graphics.newCanvas w h)))

(local scale 1)

(var (mode mode-name) nil)

(fn set-mode [new-mode-name ...]
  (let [mode-paths :src.modes. 
        mode-path (.. mode-paths new-mode-name)]
    (set (mode mode-name) (values (require mode-path) new-mode-name)))
  (when mode.activate
    (match (pcall mode.activate ...)
      (false msg) (print mode-name "activate error" msg))))

(fn live-reload-mode [mode-name loaded-assets]
  (let [mode-path (.. :src.modes. mode-name)
        args {:assets loaded-assets}]
    (lume.hotswap mode-path)
    ;; TODO: add all files that could have changed
    ; (lume.hotswap :src...)
    (set-mode mode-name args)))

(fn love.load [args]
  (set-mode :intro)
  (canvas:setFilter "nearest" "nearest")
  (when (~= :web (. args 1)) (repl.start)))

(fn safely [f]
  (xpcall f #(set-mode :error mode-name $ (fennel.traceback))))

(fn love.draw []
  ;; the canvas allows you to get sharp pixel-art style scaling; if you
  ;; don't want that, just skip that and call mode.draw directly.
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (when (and (= "table" (type mode)) mode.update)
    (safely mode.draw))
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 scale scale))

(fn love.update [dt]
  (when (and (= :table (type mode)) mode.update)
    (safely #(mode.update dt set-mode))))

(fn love.keypressed [key]
  (if 
    (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
    (love.event.quit)

    (= key "r")
    (let [args {}]
      (live-reload-mode mode-name args))

     ;; add what each keypress should do in each mode
    (safely #(mode.keypressed key set-mode))))


(comment 
  ;; REPL driven for hot reloading a mode
  ;; 1. First evaluate the whole buffer
  ;; 2. Evaluate the s-expression below
  ;; [optional] set a nvim mark and eval with conjure <LocalLeader>emF
  (let [mode-name :two
  ;; 3. Iterate quickly on the draw function or update logic
        args {:font-size 50}]
    (live-reload-mode mode-name args)))
