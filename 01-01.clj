; Fuel required to launch a given module is based on its mass. Specifically,
; to find the fuel required for a module, take its mass, divide by three,
; round down, and subtract 2

(def input (slurp "./01.input")

(defn fuel-required
  [mass]
  (- (Math/floor (/ mass 3.0)) 2))

(println (apply + (map fuel-required input)))
