(ns aoc-2024.day6
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day6.txt"
      io/reader
      line-seq
      (mapv vec)))

(def input-ex
  (->> "resources/day6ex.txt"
      io/reader
      line-seq
      (mapv vec)))

(defn get-start-pos [data]
  (reduce
   #(when (= \^ (get-in data %2)) (reduced %2))
   nil
   (for [i (range (count data)) j (range (count (first data)))]
     [i j])))

(def next-direction
  {:north :east
   :east :south
   :south :west
   :west :north})

(defn move [[x y] dir]
  (case dir
    :north [(dec x) y]
    :east [x (inc y)]
    :south [(inc x) y]
    :west [x (dec y)]))

(defn path [data]
  (loop [pos (get-start-pos data) dir :north visited #{pos}]
    (let [next (move pos dir) spot (get-in data next)]
      (case spot
        nil visited
        \# (recur pos (next-direction dir) visited)
        \^ (recur next dir (conj visited next))
        \. (recur next dir (conj visited next))))))

(defn part-1 [data]
  (count (path data)))

(part-1 input)

(defn loop? [start start-dir board]
  (loop [pos start
         dir start-dir
         seen #{}]
    (let [pos' (move pos dir)
          spot (get-in board pos')]
      (if (seen [pos' dir])
        true
        (case spot
          \# (recur pos (next-direction dir) (conj seen [pos dir]))
          (\. \^) (recur pos' dir seen)
          nil false)))))

(defn part-2 [data]
  (let [path (path data) start (get-start-pos data)
        loop? (partial loop? start :north)
        boards (for [p path :when (not= p start)] (assoc-in data p \#))]
    (->> boards
         (filter loop?)
          count)))

(part-2 input-ex)
(part-2 input)

(defn part-2-pmap [data]
  (let [path (path data) start (get-start-pos data)
        loop? (partial loop? start :north)
        boards (for [p path :when (not= p start)] (assoc-in data p \#))]
    (->> boards
         (pmap loop?)
         (filter true?)
         count)))

(part-2-pmap input-ex)
(part-2-pmap input)
