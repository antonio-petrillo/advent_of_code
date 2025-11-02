(ns aoc.day10
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(def matrix
  (->> "resources/day10.txt"
       io/reader
       line-seq
       (mapv #(into [] %))))

(def matrix-sample
  (->> "resources/day10-sample.txt"
       io/reader
       line-seq
       (mapv #(into [] %))))

(defn valid-pos-builder [row-size col-size]
  (fn [[row col]]
   (and (< -1 row row-size)
        (< -1 col col-size))))

(def directions
  {:north [-1 0]
   :south [1 0]
   :west [0 -1]
   :east [0 1]})

(defn find-starting-pos [matrix row-size col-size]
  (first (for [i (range row-size) j (range col-size)
               :when (= \S (get-in matrix [i j]))]
           [i j])))

(defn walk [pos direction]
  (mapv + pos (direction directions)))

(def next-direction
  {\- {:east :east
       :west :west}
   \| {:north :north
       :south :south}
   \L {:south :east
       :west :north}
   \7 {:east :south
       :north :west}
   \J {:south :west
       :east :north}
   \F {:north :east
       :west :south}})

(def initial-directions
  {:north #{\F \| \7}
   :south #{\L \| \J}
   :east #{\7 \J \-}
   :west #{\L \F \-}})

(defn find-initial-directions [matrix [row col] valid?]
  (let [near-fn (fn [[direction [delta-row delta-col]]]
                                (let [next-pos [(+ delta-row row) (+ delta-col col)]]
                                  (if (and (valid? next-pos) ((initial-directions direction) (get-in matrix next-pos)))
                                    direction
                                    nil)))]
    (remove nil? (map near-fn {:east [0 1] :west [0 -1] :south [1 0] :north [-1 0]}))))

(defn solution-1 [matrix]
  (let [row-size (count matrix) col-size (count (first matrix))
        valid? (valid-pos-builder row-size col-size)
        starting-pos (find-starting-pos matrix row-size col-size)
        [direction-1 direction-2] (find-initial-directions matrix starting-pos valid?)]
    (loop [pos-1 starting-pos direction-1 direction-1
           pos-2 starting-pos direction-2 direction-2
           distance 0]
      (if (and (= pos-1 pos-2) (not= starting-pos pos-1))
        distance
        (let [pos-1 (walk pos-1 direction-1)
              pos-2 (walk pos-2 direction-2)
              tile-1 (get-in matrix pos-1)
              tile-2 (get-in matrix pos-2)]
          (recur pos-1 (get-in next-direction [tile-1 direction-1])
                 pos-2 (get-in next-direction [tile-2 direction-2])
                 (inc distance)))))))

(solution-1 matrix)

(def s-replace
  {#{:north :south} \|
   #{:west :east} \-
   #{:south :west} \F
   #{:north :east} \L
   #{:north :west} \J
   #{:south :east} \7})

(defn get-boundaries [matrix row-size col-size valid?]
  (let [starting-pos (find-starting-pos matrix row-size col-size)
        [start-dir-1 start-dir-2] (find-initial-directions matrix starting-pos valid?)]
    (loop [pos-1 starting-pos direction-1 start-dir-1
           pos-2 starting-pos direction-2 start-dir-2
           visited #{starting-pos}]
      (if (and (= pos-1 pos-2) (not= starting-pos pos-1))
        {:boundaries visited :start starting-pos :replace (s-replace #{start-dir-1 start-dir-2})}
        (let [pos-1 (walk pos-1 direction-1)
              pos-2 (walk pos-2 direction-2)
              tile-1 (get-in matrix pos-1)
              tile-2 (get-in matrix pos-2)]
          (recur pos-1 (get-in next-direction [tile-1 direction-1])
                 pos-2 (get-in next-direction [tile-2 direction-2])
                 (reduce conj visited [pos-1 pos-2])))))))

(defn clear-matrix [matrix]
  (let [row-size (count matrix)
        col-size (count (first matrix))
        valid? (valid-pos-builder row-size col-size)
        boundaries (get-boundaries matrix row-size col-size valid?)
        coords (for [i (range row-size) j (range col-size)] [i j])
        path (:boundaries boundaries)]
    (reduce
     (fn [m coord]
       (if (path coord)
         m
         (assoc-in m coord \.)))
     (assoc-in matrix (:start boundaries) (:replace boundaries))
     coords)))

(defn raycast [line index char]
  (if (not= \. char)
    0
    (let [size (count line)]
      (loop [count 0
             index index
             ignore nil]
        (cond (= index size) (if (odd? count) 1 0)
              (#{\7 \J \| \F \L} (nth line index)) (if (= ignore (nth line index))
                                                     (recur count (inc index) nil)
                                                     (recur (inc count) (inc index)
                                                            (cond (= \F (nth line index)) \J
                                                                  (= \L (nth line index)) \7
                                                                  :else ignore)))
              :else (recur count (inc index) ignore))))))

(defn count-with-raycast [line]
  (let [raycast-fn (partial raycast line)]
    (->> line
         (map-indexed raycast-fn)
         (reduce + 0))))

(defn solution-2 [matrix]
  (let [clear (clear-matrix matrix)]
    (->> clear
         (map count-with-raycast)
         (reduce + 0))))

(solution-2 matrix-sample)

(solution-2 matrix)
