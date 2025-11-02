(ns aoc.day9
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(defn parse-line-1 [line]
  (let [nums (reverse (re-seq #"-?\d+" line))]
    (map parse-long nums)))

(defn parse-line-2 [line]
  (let [nums (re-seq #"-?\d+" line)]
    (map parse-long nums)))

(defn input [parse-fn]
  (map parse-fn
       (s/split-lines
        (->> "resources/day9.txt"
             io/reader
             slurp))))

(defn process-line [line]
  (loop [sum 0 line line]
    (if (every? zero? line)
      sum
      (recur
       (+ sum (first line))
       (->> line
            (partition 2 1)
            (map (fn [[a b]] (- a b))))))))

(defn solution-1 []
  (->> (input parse-line-1)
       (map process-line)
       (reduce + 0)))

(solution-1)

(defn solution-2 []
  (->> (input parse-line-2)
       (map process-line)
       (reduce + 0)))

(defn solution-2-bad []
  (->> (input parse-line-1)
       (map (comp process-line reverse))
       (reduce + 0)))

(solution-2)

(time (solution-1))
(time (solution-2))
(time (solution-2-bad))
