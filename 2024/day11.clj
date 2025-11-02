(ns aoc-2024.day11
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day11.txt"
       slurp
       (re-seq #"\d+")
       (map parse-long)))

(defn rule-1 [_]
  '(1))

(defn rule-2 [s size]
  (let [half (quot size 2)]
    (list (parse-long (subs s 0 half)) (parse-long (subs s half)))))

(defn rule-3 [stone]
  (list (* stone 2024)))

(defn apply-rule [stone]
  (let [s (str stone) size (count s)]
    (cond
      (zero? stone) (rule-1 stone)
      (even? size) (rule-2 s size)
      :else (rule-3 stone))))

(defn blink [stones]
  (mapcat apply-rule stones))

(defn part-1 [data]
  (count (reduce (fn [d _] (blink d)) data (range 25))))

(part-1 input)

(defn blink-2 [cache i stone]
  (let [found (@cache [stone i])]
    (if found
      found
      (if (zero? i)
        (do
          (swap! cache assoc [stone i] 1)
          1)
        (let [s (str stone) size (count s) half (quot size 2) found (@cache [stone i])]
          (cond
            found found
            (zero? stone) (let [c (blink-2 cache (dec i) 1)]
                            (swap! cache assoc [0 i] c)
                            c)
            (even? size) (let [c1 (blink-2 cache (dec i) (parse-long (subs s 0 half)))
                               c2 (blink-2 cache (dec i) (parse-long (subs s half)))]
                           (swap! cache assoc [stone i] (+ c1 c2))
                           (+ c1 c2))
            :else (let [c (blink-2 cache (dec i) (* 2024 stone))]
                    (swap! cache assoc [stone i] c)
                    c)))))))

(defn part-2 [data]
  (let [cblink-2 (partial blink-2 (atom {}) 75)]
    (->> data
         (pmap cblink-2)
         (reduce + 0))))

(part-2 input)
