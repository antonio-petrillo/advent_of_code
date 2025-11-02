(ns aoc-2024.day1
  (:require [clojure.java.io :as io]))

(def input
  (->> "resources/day1.txt"
       io/reader
       line-seq
       (map (partial re-seq #"\d+"))
       (apply (partial map vector))
       (map #(map parse-long %))
       (map sort)))

(defn part-1 [data]
  (->> data
       (apply map vector)
       (map (fn [[col1 col2]] (abs (- col2 col1))))
       (reduce + 0)))

(part-1 input)

(defn part-2 [data]
  (let [occurrences
        (->> (second data)
             (group-by identity)
             (map (fn [[id v]] (vector id (count v))))
             (reduce conj {}))]
    (reduce
     (fn [acc el]
       (+ acc (* el (get occurrences el 0)))) 0 (first data))))

(part-2 input)
