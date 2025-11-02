(ns aoc.day7
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def card-values (zipmap '("2" "3" "4" "5" "6" "7" "8" "9" "T" "J" "Q" "K" "A") (range 1 14)))

(def ranks (zipmap '(:high-card :pair :two-pair :three-of-a-kind :straight :flush :full-house :four-of-a-kind :straight-flush :five-of-a-kind) (range)))

(def hand-types
  {'(5) :five-of-a-kind
   '(1 4) :four-of-a-kind
   '(2 3) :full-house
   '(1 1 3) :three-of-a-kind
   '(1 2 2) :two-pair
   '(1 1 1 2) :one-pair
   '(1 1 1 1 1) :high-card})

(def types-rank
  (zipmap
   '(:high-card :one-pair :two-pair :three-of-a-kind :full-house :four-of-a-kind :five-of-a-kind)
   (range)))

(defn hand->type [hand-values]
  (->> hand-values
       (group-by identity)
       (map (comp count second))
       sort
       hand-types))

(defn parse-hand [line]
  (let [[cards bid] (s/split line #"\s")
        parsed (->> cards
                (re-seq #"[2-9TJQKA]"))
        values (map #(card-values %) parsed)]
    {:hand parsed
     :hand-values values
     :type (hand->type values)
     :jollies (count (re-seq #"J" cards))
     :bid (parse-long bid)}))

(defn parse-input [parse-fn]
  (->> "resources/day7.txt"
       io/reader
       line-seq
       (map parse-fn)))

(defn first-high [a b]
  (loop [[a & rem-a] a [b & rem-b] b]
    (cond (nil? a) 0
          (< a b) -1
          (> a b) 1
          :else (recur rem-a rem-b))))

(defn hand-comparator [a b]
  (let [rank-1 ((comp types-rank :type) a)
        rank-2 ((comp types-rank :type) b)
        order (compare rank-1 rank-2)]
    (if (zero? order)
      (first-high (:hand-values a) (:hand-values b))
      order)))

(defn solution-1 []
  (let [input (parse-input parse-hand)]
    (->> input
         (sort hand-comparator)
         (map-indexed (fn [index hand]
                        (* (inc index) (:bid hand))))
         (reduce + 0))))

(solution-1)

(def card-values-2 (zipmap '("J" "2" "3" "4" "5" "6" "7" "8" "9" "T" "Q" "K" "A") (range 1 14)))

(def skip-list
  { :high-card {1 :one-pair }
    :one-pair {1 :three-of-a-kind 2 :three-of-a-kind }
    :two-pair {2 :four-of-a-kind 1 :full-house }
    :three-of-a-kind {1 :four-of-a-kind 3 :four-of-a-kind}
    :full-house {2 :five-of-a-kind 3 :five-of-a-kind}
    :four-of-a-kind {1 :five-of-a-kind 4 :five-of-a-kind}
    :five-of-a-kind {5 :five-of-a-kind}})

(defn parse-hand-2 [line]
  (let [[cards bid] (s/split line #"\s")
        parsed (->> cards
                (re-seq #"[2-9TJQKA]"))
        values (map #(card-values-2 %) parsed)
        type (hand->type values)
        jollies (count (re-seq #"J" cards))]
    {:hand parsed
     :hand-values values
     :type (get-in skip-list [type jollies] type)
     :bid (parse-long bid)}))

(defn solution-2 []
  (let [input (parse-input parse-hand-2)]
    (->> input
         (sort hand-comparator)
         (map-indexed (fn [index hand]
                        (* (inc index) (:bid hand))))
         (reduce + 0))))

(solution-2)
