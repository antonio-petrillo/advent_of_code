(ns aoc.day13
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (let [blocks (s/split (->> "resources/day13.txt"
                   io/reader
                   slurp) #"\n\n")]
    (mapv #(into [] (s/split-lines %)) blocks)))

(defn count-rows [stop? block]
  (reduce
   (fn [_ size]
     (let [[above below] (split-at size block)
           above (reverse above)]
       (if (stop? above below)
         (reduced size)
         0)))
   (range (count block))))

(defn count-reflections [stop? block]
  (+ (* 100 (count-rows stop? block))
     (count-rows stop? (apply map vector block))))

(defn solution [stop? input]
  (->> input
       (map (partial count-reflections stop?))
       (reduce + 0)))

(defn reflection? [aboves belows]
  (every? true? (map #(= %1 %2) aboves belows)))

(def solution-1
  (partial solution reflection?))

(solution-1 input)

(defn hamming-diff
  "Count the difference in the two rows
   See [exercism](https://exercism.org/tracks/clojure/exercises/hamming)"
  [row-1 row-2]
  (->> (map = (seq row-1) (seq row-2))
       (filter false?)
       count))

(def one?
  #(= 1 %))

;; the problems guarantees that there is only one smudge
(defn smudge?
  "found the smudge only when the hamming difference is exactly `1`"
  [aboves belows]
  (one? (reduce + 0 (map hamming-diff aboves belows))))

(def solution-2
  (partial solution smudge?))

(solution-2 input)
