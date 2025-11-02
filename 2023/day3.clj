(ns aoc.day3
  (:require [clojure.java.io :as io]))

(defn valid-pos? [max-row max-col]
  (fn [[row col]]
      (and
       (< -1 row max-row)
       (< -1 col max-col))))

(def offsets (for [delta-row [-1 0 1] delta-col [-1 0 1]
                   :when (not= 0 delta-row delta-col)]
               [delta-row delta-col]))

(defn neighbours [valid? [row col]]
  (for [[delta-row delta-col] offsets
        :let [neighbour [(+ row delta-row) (+ col delta-col)]]
        :when (valid? neighbour)]
    neighbour))

(defn symbol? [c]
  (and
   (not= c \.)
   (not (Character/isDigit c))))

(defn near-to-symbol? [matrix valid? pos]
  (->> pos
       (neighbours valid?)
       (map (comp symbol? (partial get-in matrix)))
       (some true?)))

(defn reduce-row [matrix max-col valid? row-index]
  (loop [col 0 readed "" valid nil sum 0]
    (if (< col max-col)
      (let [c (get-in matrix [row-index col])]
        (cond (Character/isDigit c) (recur (inc col)
                                           (str readed c)
                                           (or valid
                                               (near-to-symbol? matrix valid? [row-index col]))
                                           sum)
              (empty? readed) (recur (inc col) "" nil sum)
              :else (recur (inc col) "" nil
                           (+ sum (if valid (Integer/parseInt readed) 0)))))
      (+ sum (if valid (Integer/parseInt readed) 0)))))

(defn solution-1 []
  (let [matrix (->> "resources/day3.txt"
                    io/reader
                    line-seq
                    (mapv #(into [] %)))
        max-col (count (first matrix))
        max-row (count matrix)
        valid-pos? (valid-pos? max-row max-col)
        reduce-row (partial reduce-row matrix max-col valid-pos?)]
    (->> (range max-row)
         (map reduce-row)
         (reduce + 0))))

(solution-1)

(defn gear? [c]
  (= \* c))

(defn gears-pos-in-row [matrix row]
  (remove nil? (map-indexed
               #(if (gear? %2) (vector row %1) nil)
               (get matrix row))))

(defn all-gears [matrix num-row]
  (mapcat (partial gears-pos-in-row matrix) (range num-row)))

(defn read-number-in-direction [matrix valid? [row col] inc-f]
  (loop [readed "" col col]
    (let [c (get-in matrix [row col])]
          (if (and (valid? [row col]) (Character/isDigit c))
            (recur (str c readed) (inc-f col))
            readed))))

(defn read-number-at-pos [matrix valid? [row col :as pos]]
  (if (Character/isDigit (get-in matrix pos))
    (let [read-dir (partial read-number-in-direction matrix valid?)
          left (read-dir pos dec)
          right (apply str (reverse (read-dir [row (inc col)] inc)))]
      (Integer/parseInt (str left right)))
    nil))

(defn near-gear-number [matrix valid? pos]
  (let [near-numbers (->> pos
                          (neighbours valid?)
                          (map (comp (partial read-number-at-pos matrix valid?)))
                          (remove nil?)
                          (into #{}))]
    (if (= 2 (count near-numbers))
      (apply * near-numbers)
      0)))

(defn solution-2 []
  (let [matrix (->> "resources/day3.txt"
                    io/reader
                    line-seq
                    (mapv #(into [] %)))
        max-col (count (first matrix))
        max-row (count matrix)
        valid-pos? (valid-pos? max-row max-col)
        gears (into #{} (all-gears matrix max-row))]
    (loop [[gear & gears] gears sum 0]
      (if (nil? gears)
        sum
        (recur gears (+ sum (near-gear-number matrix valid-pos? gear)))))))

(solution-2)
