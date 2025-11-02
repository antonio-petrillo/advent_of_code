(ns aoc.day6
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(defn read-races []
  (->> "resources/day6.txt"
       io/reader
       line-seq
       (map #(re-seq #"\d+" %))
       (map (fn [row] (map parse-long row)))
       (apply (partial mapv vector))))

(def races (read-races))

(defn race->winning-strat [[time distance]]
  (loop [pressed 0 time time strats 0 first-found false]
    (let [distance-runned (* pressed time)]
      (cond (> distance-runned distance) (recur (inc pressed) (dec time) (inc strats) true)
            (and (<= distance-runned distance) first-found) strats
            :else (recur (inc pressed) (dec time) strats false)))))

(defn solution-1 []
  (->> races
       (map race->winning-strat)
       (reduce * 1)))

(solution-1)

(defn read-races-part2 []
  (->> "resources/day6.txt"
       io/reader
       line-seq
       (map #(s/replace % #"[^0-9]" ""))
       (mapv parse-long)))

(defn solution-2 []
  (race->winning-strat (read-races-part2)))

(solution-2)

(defn math-race->winning-strat [[time distance]]
  (let [discriminant (Math/sqrt (- (* time time) (* 4 distance)))
        lower (int (Math/ceil (/ (- time discriminant) 2)))
        higher (int (Math/ceil (/ (+ time discriminant) 2)))]
    (- higher lower)))

(defn fast-solution-1 []
  (->> races
       (map math-race->winning-strat)
       (reduce * 1)))

(defn fast-solution-2 []
  (math-race->winning-strat (read-races-part2)))

(time (solution-1))
;; Elapsed time: 0.269208 msecs
(time (solution-2))
;; Elapsed time: 1503.808583 msecs

(time (fast-solution-1))
;; Elapsed time: 0.125 msecs
(time (fast-solution-2))
;; Elapsed time: 0.625042 msecs
