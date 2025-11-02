(ns aoc-2024.day12
  (:require [clojure.java.io :as io]
            [clojure.string :as s]
            [clojure.set :as set]))

(def input
  (->> "resources/day12.txt"
       io/reader
       line-seq
       (map #(re-seq #"[A-Z]" %))
       (mapv #(mapv identity %))))

(def input-ex
  (->> "resources/day12ex.txt"
       io/reader
       line-seq
       (map #(re-seq #"[A-Z]" %))
       (mapv #(mapv identity %))))

(defn bfs-frontier [map seen [r c :as pos]]
  (let [type (get-in map pos)]
    (for [[dr dc] '([0 1] [0 -1] [1 0] [-1 0])
          :let [pos' [(+ r dr) (+ c dc)]]
          :when (and (not (seen pos')) (= type (get-in map pos')))]
      pos')))

(defn bfs [input p]
  (loop [q (conj clojure.lang.PersistentQueue/EMPTY p) seen #{p}]
    (if (empty? q)
      seen
      (let [p' (peek q) q' (pop q) frontier (bfs-frontier input seen p')]
        (recur (reduce conj q' frontier) (reduce conj seen frontier))))))

(defn flood-fill-gardens [input]
  (loop [indexes (set (for [i (range (count input)) j (range (count (first input)))]
                   [i j])) gardens #{}]
    (if (empty? indexes)
      gardens
      (let [garden (bfs input (first indexes))]
        (recur (set/difference indexes garden) (conj gardens garden))))))

(defn garden->price-by-perimeter [garden]
  (let [size (count garden)]
    (->> garden
         (map (fn [[r c]] (- 4 (count (for [[dr dc] '([0 1] [0 -1] [1 0] [-1 0])
                                            :let [p' [(+ r dr) (+ c dc)]]
                                            :when (garden p')]
                                        :fence)))))
         (reduce + 0)
         (* size))))

(defn part-1 [input]
  (->> input
       flood-fill-gardens
       (map garden->price-by-perimeter)
       (reduce + 0)))

(part-1 input-ex)
(part-1 input)

(defn remove-inners-field [garden]
  (->> garden
       (remove (fn [[r c]] (= 4 (count (for [[dr dc] '([0 1] [0 -1] [1 0] [-1 0])
                                                :let [p' [(+ r dr) (+ c dc)]]
                                                :when (garden p')]
                                            :connected)))))))

(defn block->edges [[r c]]
  (list [(- r 0.5) (+ c 0.5)]
        [(+ r 0.5) (+ c 0.5)]
        [(+ r 0.5) (- c 0.5)]
        [(- r 0.5) (- c 0.5)]))

(defn edges->block [p]
  (->> p
       block->edges
       (map (fn [[r c]] [(long r) (long c)]))))

(defn count-edges [garden p]
  (let [connections (->> p edges->block (map (partial contains? garden))) rank (->> connections (filter true?) count)]
    (println connections rank)
    (case rank
      1 1
      2 (if (or (= connections [true false true false]) (= connections [false true false true]))
          2
          0)
      3 1
      0)))

(defn count-corners [garden]
  (let [maybe-edges (->> garden remove-inners-field (mapcat block->edges) (into #{}))]
    (->> maybe-edges
         (map (partial count-edges garden))
         (reduce + 0))))

(defn garden->price-by-sides [garden]
  (let [size (count garden)]
    (if (= 1 size)
      4
      (->> garden
           count-corners
           (* size)))))

(defn part-2 [input]
  (->> input
       flood-fill-gardens
       (map garden->price-by-sides)
       (reduce + 0)))

(part-2 input-ex)
(part-2 input)
