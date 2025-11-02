(ns aoc-2024.day5
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(defn parse-rules [rules]
  (->> rules
       s/split-lines
       (map #(->> (s/split % #"\|") (map parse-long)))
       (reduce (fn [m pair] (-> m (assoc pair true) (assoc (reverse pair) false))) {})))

(defn parse-updates [updates]
  (->> updates
       s/split-lines
       (map #(->> (s/split % #",") (map parse-long) vec))))

(def input
  (let [data (-> (slurp "resources/day5.txt")
                 (s/split #"\n\n"))]
    { :rules (parse-rules (first data)) :updates (parse-updates (second data)) }))

(defn valid-update-on-rules? [rules update]
  (let [size (count update)
        combs (for [i (range (dec size)) j (range (inc i) size)]
                (vector (nth update i) (nth update j)))]
    (reduce
     (fn [_ edge]
       (if (and (contains? rules edge) (not (get rules edge)))
         (reduced false)
         true))
     true
     combs)))

(defn part-1 [{:keys [rules updates]}]
  (let [valid? (partial valid-update-on-rules? rules)]
    (->> updates
         (filter valid?)
         (map #(nth % (quot (count %) 2)))
         (reduce + 0))))

(part-1 input)

(defn sorter [rules]
  (let [rules (into {}
                    (map (fn [[xy v]]
                     (if v
                       [xy -1]
                       [xy 1])) rules))]
    (fn [x y]
      (rules [x y]))))

(defn part-2 [{:keys [rules updates]}]
  (let [valid? (partial valid-update-on-rules? rules)
        by (sorter rules)]
    (->> updates
         (remove valid?)
         (map (partial sort by))
         (map #(nth % (quot (count %) 2)))
         (reduce + 0))))

(part-2 input)
