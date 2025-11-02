(ns aoc.day4
  (:require [clojure.java.io :as io]
            [clojure.set :as set]))

(defn line->card [line]
  (let [line (->> line
                  (drop-while #(not= \: %))
                  (drop 2)
                  (apply str))
        numbers (->> line
                     (re-seq #"\d+")
                     (map #(Integer/parseInt %)))]
    {:winner (into #{} (take 10 numbers)) :hand (into #{} (drop 10 numbers))}))

(defn card-matches [card]
  (set/intersection (:winner card) (:hand card)))

(defn card->points [card]
  (let [valid (card-matches card)]
    (if (empty? valid)
      0
      (bit-shift-left 1 (dec (count valid))))))

(defn solution-1 []
  (->> "resources/day-4.txt"
       io/reader
       line-seq
       (map (comp card->points line->card))
       (reduce + 0)))

(solution-1)

(defn solution-2 []
  (let [cards (->> "resources/day-4.txt"
                   io/reader
                   line-seq
                   (map (comp #(hash-map :win % :copies 1) count card-matches line->card))
                   (zipmap (range))
                   (into (sorted-map)))
        size (count cards)]
    (->> (range size)
         (reduce
          (fn [cards id]
            (let [card (cards id)
                  win (:win card)
                  copies (:copies card)
                  ids-below (for [i (range 1 (inc win))
                                  :let [id-below (+ id i)]
                                  :when (< id-below size)]
                              id-below)]
              (reduce
               (fn [cards id-below]
                 (update-in cards [id-below :copies] #(+ % copies)))
               cards
               ids-below)))
          cards)
         (map (comp :copies second))
         (reduce + 0))))

(solution-2)
