(ns aoc-2024.day2
  (:require [clojure.java.io :as io]))

(def input
  (->> "resources/day2.txt"
       io/reader
       line-seq
       (map (partial re-seq #"\d+"))
       (map #(map parse-long %))))

(defn safe-line? [line]
  (let [deltas (->> line
                    (partition 2 1)
                    (map #(- (first %) (second %))))]
    (or (every? #(<= 1 % 3) deltas)
        (every? #(<= -3 % -1) deltas))))

(defn part-1 [data]
  (->> data
       (filter safe-line?)
       count))

(part-1 input)

(defn combs [line]
  (let [line (vec line)]
    (for [i (range (count line))]
      (reduce conj (subvec line 0 i) (drop (inc i) line)))))

(defn safe-line-tolerate-one-unsafe? [line]
  (->> line
       combs
       (some safe-line?)))

(defn part-2 [data]
  (->> data
       (filter safe-line-tolerate-one-unsafe?)
       count))

(part-2 input)
