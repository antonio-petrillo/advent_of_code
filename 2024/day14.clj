(ns aoc-2024.day14
  (:require [clojure.java.io :as io]
            [clojure.string :as s]
            [clojure.set :as set]))

(defn parse-robot [line]
  (->> line
       (re-seq #"-?\d+")
       (mapv parse-long)))

(def input
  (->> "resources/day14.txt"
       io/reader
       line-seq
       (mapv parse-robot)))

(def height 103)
(def width 101)

(defn move-robot [times [x y vx vy]]
  (let [c (mod (+ x (* times vx)) width)
        r (mod (+ y (* times vy)) height)]
    [r c]))

(defn count-quadrants [m]
  (let [half-h (quot height 2) half-w (quot width 2)]
    (loop [q1 0 q2 0 q3 0 q4 0
           [index & indexes] (for [i (range height) j (range width) :when (and (not= i half-h) (not= j half-w))] [i j])]
      (if (nil? index)
        [q1 q2 q3 q4]
        (let [[i j] index robots (get-in m index)] 
          (cond
            (and (< i half-h) (< j half-w)) (recur (+ q1 robots) q2 q3 q4 indexes)
            (and (< i half-h) (> j half-w)) (recur q1 (+ q2 robots) q3 q4 indexes)
            (and (> i half-h) (< j half-w)) (recur q1 q2 (+ q3 robots) q4 indexes)
            (and (> i half-h) (> j half-w)) (recur q1 q2 q3 (+ q4 robots) indexes)))))))

(defn out []
  (let [row (vec (repeat width 0))
        out (into [] (repeat height row))]
    out))

(defn part-1
  ([input] (part-1 input 100))
  ([input seconds]
    (->> input
         (map (partial move-robot seconds))
         (reduce #(update-in %1 %2 inc) (out))
         count-quadrants
         (apply *))))

(part-1 input)

;; Thanks to Hyper Neutrino https://www.youtube.com/watch?v=ySUUTxVv31U
(defn part-2 [input]
  (let [seconds (range (* 101 103))
        counts (map (partial part-1 input) seconds)
        epochs (reduce conj (sorted-map) (zipmap counts seconds))]
    (->> epochs first second)))

(part-2 input)
