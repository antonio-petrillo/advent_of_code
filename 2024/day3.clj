(ns aoc-2024.day3
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day3.txt"
       io/reader
       line-seq
       (mapcat (partial re-seq #"don't\(\)|do\(\)|mul\((\d{1,3}),(\d{1,3})\)"))))

(defn part-1 [data]
  (->> data
       (filter #(s/starts-with? (first %) "mul"))
       (map (fn [[_ x y]] (* (parse-long x) (parse-long y))))
       (reduce + 0)))

(part-1 input)

(defn- keep? [acc match]
  (condp = (subs (first match) 0 3)
    "do(" (assoc acc :keep true)
    "don" (assoc acc :keep false)
    "mul" (if (:keep acc) (update acc :data conj (rest match)) acc)))

(defn part-2 [data]
  (->> data
       (reduce keep? {:keep true :data []})
       :data
       (map #(map parse-long %))
       (map (partial apply *))
       (reduce + 0)))

(part-2 input)
