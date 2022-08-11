(var state {:font-size 50})

(global st state)

{:draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (love.graphics.printf
          "HELLO WORLD! mode two"
          0 (- (/ h 2) 15) w :center))
 :activate (fn activate [{: font-size}]
              (set state.font-size font-size)
              (love.graphics.setNewFont font-size))
 :update (fn update [dt set-mode])
 :keypressed (fn keypressed [key set-mode]
                 (love.event.quit))}
