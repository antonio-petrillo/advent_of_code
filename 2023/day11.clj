(ns aoc.day11
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(def matrix
  (->> "resources/day11.txt"
       io/reader
       line-seq
       (mapv #(into [] %))))

(defn find-empty-rows-and-cols [matrix]
  (let [count-fn (fn [m]
                   (->> m
                        (map-indexed (fn [index row] (if (every? #(= \. %) row) index nil)))
                        (remove nil?)
                        (into #{})))
        transposed (apply map vector matrix)]
    {:rows (count-fn matrix) :columns (count-fn transposed)}))

(defn galaxies-positions [matrix row-size col-size]
  (for [i (range row-size) j (range col-size)
        :when (= \# (get-in matrix [i j]))]
    [i j]))

(defn all-galaxies-pairs [matrix row-size col-size]
  (let [positions (galaxies-positions matrix row-size col-size)]
    (loop [pairs [] [pos & positions] positions]
      (if (empty? positions)
        pairs
        (recur (into pairs (map (fn [other] [pos other]) positions) ) positions)))))

(defn distance [empty-rows empty-cols offset [[row-1 col-1] [row-2 col-2]]]
  (let [[row-small row-big] (sort [row-1 row-2])
        [col-small col-big] (sort [col-1 col-2])
        row-steps (for [row (range row-small row-big)]
                    (if (empty-rows row)
                      offset
                      1))
        col-steps (for [col (range col-small col-big)]
                    (if (empty-cols col)
                      offset
                      1))]
    (+ (reduce + 0 row-steps)
       (reduce + 0 col-steps))))

(defn optimized-distance
  "Instead of walk the range of the distances (rows and cols) just do some math"
  [empty-rows empty-cols offset [[row-1 col-1] [row-2 col-2]]]
  (let [[row-small row-big] (sort [row-1 row-2])
        [col-small col-big] (sort [col-1 col-2])
        contained? (fn [low high num] (< low num high))
        contained-row? (partial contained? row-small row-big)
        contained-col? (partial contained? col-small col-big)
        intersected-row (reduce (fn [size id] (if (contained-row? id) (inc size) size)) 0 empty-rows)
        intersected-col (reduce (fn [size id] (if (contained-col? id) (inc size) size)) 0 empty-cols)]
    (- (+ (- row-big row-small) (- col-big col-small)
          (* offset intersected-row) (* offset intersected-col))
       intersected-row intersected-col)))

(defn solution [skip-size distance matrix]
  (let [row-size (count matrix) col-size (count (first matrix))
        {:keys [rows columns]} (find-empty-rows-and-cols matrix)
        pairs (all-galaxies-pairs matrix row-size col-size)
        distance-fn (partial distance rows columns skip-size)]
    (reduce + 0 (->> pairs
         (map distance-fn)))))

(def solution-1 (partial solution 2 distance))
(def solution-2 (partial solution 1000000 distance))

(def solution-1-opt (partial solution 2 optimized-distance))
(def solution-2-opt (partial solution 1000000 optimized-distance))

(solution-1 matrix)
(solution-2 matrix)

(solution-1-opt matrix)
(solution-2-opt matrix)

(time (solution-1 matrix)) ;; Elapsed time: 895.79075 msecs
(time (solution-2 matrix)) ;; Elapsed time: 902.915959 msecs

(time (solution-1-opt matrix)) ;; Elapsed time: 476.307417 msecs
(time (solution-2-opt matrix)) ;; Elapsed time: 483.133208 msecs
