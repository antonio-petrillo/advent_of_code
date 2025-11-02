(ns aoc-2024.day10
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def topomap
  (->> "resources/day10.txt"
       io/reader
       line-seq
       (map #(re-seq #"\d" %))
       (mapv #(mapv parse-long %))))

(defn next-trail [topomap [r c] h]
  (for [[dr dc] '([0 1] [0 -1] [1 0] [-1 0])
        :let [pos [(+ r dr) (+ c dc)]]
        :when (= (get-in topomap pos) (inc h))]
    pos))

(defn find-start-positions [topomap]
  (for [i (range (count topomap)) j (range (count (first topomap)))
        :when (zero? (get-in topomap [i j]))]
    [i j]))

(defn bfs [topomap start]
  (loop [q (conj clojure.lang.PersistentQueue/EMPTY start) trailheads 0 seen #{}]
    (if (empty? q)
      trailheads
      (let [pos (peek q) q (pop q) height (get-in topomap pos)]
        (if (and (= 9 height) (not (seen pos)))
          (recur q (inc trailheads) (conj seen pos))
          (recur (reduce conj q (next-trail topomap pos height)) trailheads seen))))))

(defn part-1 [topomap]
  (->> topomap
       find-start-positions
       (map (partial bfs topomap))
       (reduce + 0)))

(part-1 topomap)

(defn bfs-2 [topomap start]
  (loop [q (conj clojure.lang.PersistentQueue/EMPTY start) trailheads 0]
    (if (empty? q)
      trailheads
      (let [pos (peek q) q (pop q) height (get-in topomap pos)]
        (if (= 9 height)
          (recur q (inc trailheads))
          (recur (reduce conj q (next-trail topomap pos height)) trailheads))))))

(defn part-2 [topomap]
  (->> topomap
       find-start-positions
       (map (partial bfs-2 topomap))
       (reduce + 0)))

(part-2 topomap)
