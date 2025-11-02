(ns aoc-2024.day8
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day8.txt"
       io/reader
       line-seq
       (mapv vec)))

(defn in-bound-pred-gen [data]
  (let [row-size (dec (count data)) col-size (dec (count (first data)))]
    (fn [[r c]] (and (<= 0 r row-size) (<= 0 c col-size)))))

(defn categorize-antennas [data]
  (remove #(or (= 1 (count %)) (zero? (count %)))(map second
       (group-by
   #(get-in data %)
   (for [i (range (count data)) j (range (count (first data)))
         :let [pos [i j] antennas (get-in data pos)]
         :when (or (Character/isDigit antennas) (Character/isLowerCase antennas) (Character/isUpperCase antennas))]
     pos)))))

(defn pairs [positions]
  (let [size (count positions)]
    (for [i (range size) j (range (inc i) size)]
      [(positions i) (positions j)])))

(defn gen-pairs-pos [antennas]
  (mapcat pairs antennas))

(defn pair->antinodes [[[x1 y1] [x2 y2]]]
  (let [dx (abs (- x1 x2)) dy (abs (- y1 y2))]
    (if (<= y1 y2)
      [[(- x1 dx) (- y1 dy)] [(+ x2 dx) (+ y2 dy)]]
      [[(- x1 dx) (+ y1 dy)] [(+ x2 dx) (- y2 dy)]])))

(defn part-1 [data]
  (let [antennas (categorize-antennas data)
        in-bound? (in-bound-pred-gen data)]
    (->> antennas
         gen-pairs-pos
         (mapcat pair->antinodes)
         (reduce conj #{})
         (filter in-bound?)
         count)))

(part-1 input)

(defn proj-2-4 [b? dx dy [x1 y1 :as p1] [x2 y2 :as p2]]
  (concat
   [p1 p2]
   (for [i (range 1 1e5)
         :let [pos [(- x1 (* i dx)) (- y1 (* i dy))]]
         :while (b? pos)]
     pos)
   (for [i (range 1 1e5)
         :let [pos [(+ x2 (* i dx)) (+ y2 (* i dy))]]
         :while (b? pos)]
     pos)))

(defn proj-1-3 [b? dx dy [x1 y1 :as p1] [x2 y2 :as p2]]
  (concat
   [p1 p2]
   (for [i (range 1 1e5)
         :let [pos [(- x1 (* i dx)) (+ y1 (* i dy))]]
         :while (b? pos)]
     pos)
   (for [i (range 1 1e5)
         :let [pos [(+ x2 (* i dx)) (- y2 (* i dy))]]
         :while (b? pos)]
     pos)))

(defn pair->antinodes-projection [in-bound? [[x1 y1 :as p1] [x2 y2 :as p2]]]
  (let [dx (abs (- x1 x2)) dy (abs (- y1 y2))]
    (if (<= y1 y2)
      (proj-2-4 in-bound? dx dy p1 p2)
      (proj-1-3 in-bound? dx dy p1 p2))))

(defn part-2 [data]
  (let [antennas (categorize-antennas data)
        in-bound? (in-bound-pred-gen data)
        pair->antinodes-projection (partial pair->antinodes-projection in-bound?)]
    (->> antennas
         gen-pairs-pos
         (mapcat pair->antinodes-projection)
         (reduce conj #{})
         count)))

(part-2 input)
