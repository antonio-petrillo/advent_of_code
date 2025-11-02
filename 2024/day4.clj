(ns aoc-2024.day4
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day4.txt"
       io/reader
       line-seq
       vec))

(defn look-row [limit data i j]
  (+ (if (and (< j (- limit 3))
              (= \M (get-in data [i (+ j 1)]))
              (= \A (get-in data [i (+ j 2)]))
              (= \S (get-in data [i (+ j 3)]))) 1 0)
     (if (and (>= j 3)
              (= \M (get-in data [i (- j 1)]))
              (= \A (get-in data [i (- j 2)]))
              (= \S (get-in data [i (- j 3)]))) 1 0)))

(defn look-col [limit data i j]
  (+ (if (and (< i (- limit 3))
              (= \M (get-in data [(+ i 1) j]))
              (= \A (get-in data [(+ i 2) j]))
              (= \S (get-in data [(+ i 3) j]))) 1 0)
     (if (and (>= i 3)
              (= \M (get-in data [(- i 1) j]))
              (= \A (get-in data [(- i 2) j]))
              (= \S (get-in data [(- i 3) j]))) 1 0)))

(defn look-diag-1 [limit-row limit-col data i j]
  (+ (if (and (< i (- limit-row 3)) (< j (- limit-col 3))
              (= \M (get-in data [(+ i 1) (+ j 1)]))
              (= \A (get-in data [(+ i 2) (+ j 2)]))
              (= \S (get-in data [(+ i 3) (+ j 3)]))) 1 0)
     (if (and (>= j 3) (>= i 3)
              (= \M (get-in data [(- i 1) (- j 1)]))
              (= \A (get-in data [(- i 2) (- j 2)]))
              (= \S (get-in data [(- i 3) (- j 3)]))) 1 0)))

(defn look-diag-2 [limit-row limit-col data i j]
  (+ (if (and (>= i 3) (< j (- limit-col 3))
              (= \M (get-in data [(- i 1) (+ j 1)]))
              (= \A (get-in data [(- i 2) (+ j 2)]))
              (= \S (get-in data [(- i 3) (+ j 3)]))) 1 0)
     (if (and (>= j 3) (< i (- limit-row 3))
              (= \M (get-in data [(+ i 1) (- j 1)]))
              (= \A (get-in data [(+ i 2) (- j 2)]))
              (= \S (get-in data [(+ i 3) (- j 3)]))) 1 0)))

(defn look-for-xmas [row-len col-len data acc [ i j ] ]
  (if (= \X (get-in data [i j]))
    (+ acc
       (look-row col-len data i j)
       (look-col row-len data i j)
       (look-diag-1 row-len col-len data i j)
       (look-diag-2 row-len col-len data i j))
    acc))

(defn part-1 [data]
  (let [row-len (count data) col-len (count (nth data 0))
        look-for-xmas (partial look-for-xmas row-len col-len data)]
    (->> (for [i (range row-len) j (range col-len)]
                  [i j])
         (reduce look-for-xmas 0))))

(part-1 input)

(defn look-for-x-mas [row-len col-len data acc [ i j ] ]
  (if (and (= \A (get-in data [i j]))  (< 0 i (dec row-len)) (< 0 j (dec col-len)))
    (+ acc
       (if (and (or
                 (and (= \M (get-in data [(dec i) (dec j)]))
                      (= \S (get-in data [(inc i) (inc j)])))
                 (and (= \S (get-in data [(dec i) (dec j)]))
                      (= \M (get-in data [(inc i) (inc j)]))))
                (or
                 (and (= \M (get-in data [(dec i) (inc j)]))
                      (= \S (get-in data [(inc i) (dec j)])))
                 (and (= \S (get-in data [(dec i) (inc j)]))
                      (= \M (get-in data [(inc i) (dec j)]))))) 1 0))
    acc))

(defn part-2 [data]
  (let [row-len (count data) col-len (count (nth data 0))
        look-for-x-mas (partial look-for-x-mas row-len col-len data)]
    (->> (for [i (range row-len) j (range col-len)]
                  [i j])
         (reduce look-for-x-mas 0))))

(part-2 input)
