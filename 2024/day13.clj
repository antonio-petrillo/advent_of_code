(ns aoc-2024.day13
  (:require [clojure.java.io :as io]
            [clojure.string :as s]
            [clojure.set :as set]))

(defn parse-system [system]
  (let [[[x1 y1] [x2 y2] sol] (->> system
               s/split-lines
               (map #(re-seq #"\d+" %))
               (mapv #(mapv parse-long %)))]
    [[x1 x2] [y1 y2] sol]))

(def input
  (let [in (slurp "resources/day13.txt")]
    (->> (s/split in #"\n\n")
         (map parse-system))))

(defn solve [[[x1 x2] [y1 y2] [z1 z2]]]
  (let [ b (quot (- (* x1 z2) (* y1 z1)) (- (* x1 y2) (* y1 x2)))
         a (quot (- z1 (* x2 b)) x1)
        sol [(+ (* x1 a) (* x2 b)) (+ (* y1 a) (* y2 b))]]
    (if (not= [z1 z2] sol)
      0
      (+ (* 3 a) b))))

(defn part-1 [input]
  (->> input
       (map solve)
       (reduce + 0)))

(part-1 input)

(defn part-2 [input]
  (->> input
       (map (fn [[x y [z1 z2]]] [x y [(+ z1 10000000000000) (+ z2 10000000000000)]]))
       (map solve)
       (reduce + 0)))

(part-2 input)
