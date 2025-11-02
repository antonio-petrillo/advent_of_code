(ns aoc.day2
  (:require [clojure.java.io :as io]))

(def amount-1
  {"red" 12 "green" 13 "blue" 14})

(defn possible? [game]
  (->> game
       (map (fn [[k v]] (<= v (amount-1 k))))
       (filter false?)
       count
       zero?))

(defn parse-line [line]
  (let [id (re-find #"[0-9]+:" line)
        id (Integer/parseInt (subs id 0 (dec (count id))))
        game (map (fn [[_ num color]]
                    [color (Integer/parseInt num)])
                  (re-seq #"([0-9]+) (blue|red|green)" line))]
    {:id id :game game}))


(defn solution-1 []
  (->> "resources/day-2.txt"
       io/reader
       line-seq
       (map parse-line)
       (filter (comp possible? :game))
       (reduce (fn [result game] (+ result (:id game))) 0)))

(solution-1)

(defn power [game]
  (->> (reduce (fn [[red green blue] cubes]
                 (let [[color nums] cubes]
                 (cond (= "red" color) [(max red nums) green blue]
                       (= "green" color) [red (max green nums) blue]
                       :else [red green (max blue nums)])))
               [1 1 1] (:game game))
       (apply *)))

(defn solution-2 []
  (->> "resources/day-2.txt"
       io/reader
       line-seq
       (map (comp power parse-line))
       (reduce + 0)))

(solution-2)
