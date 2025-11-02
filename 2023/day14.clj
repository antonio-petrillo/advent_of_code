(ns aoc.day14
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day14.txt"
       io/reader
       line-seq
       (mapv #(into [] %))))

(defn boulder? [c]
  (= \O c))

(defn dot? [c]
  (= \. c))

(defn sharp? [c]
  (= \# c))

(defn first-dot [line]
  (reduce
   (fn [index c] (if (dot? c) (reduced index) (inc index)))
   0
   line))

(defn find-next-dot [line index]
  (loop [index index]
    (if (or (= index (count line))
            (dot? (nth line index)))
      index
      (recur (inc index)))))

(defn move-north [line]
  (let [size (count line)
        start (first-dot line)]
    (loop [i start j (inc start) u-line line]
      (cond
        (or (= i size) (= j size)) u-line
        (sharp? (nth u-line j)) (let [next-i (find-next-dot u-line (inc j))]
                                  (recur next-i (inc next-i) u-line))
        (boulder? (nth u-line j)) (let [u-line (-> u-line (assoc i \O) (assoc j \.))
                                        next-i (find-next-dot u-line i)]
                                    (recur next-i (if (<= j next-i) (inc next-i) (inc j)) u-line))
        :else (recur i (inc j) u-line)))))

(defn count-load [size line]
  (reduce (fn [sum index]
            (case (nth line index)
              \. sum
              \# sum
              \O (+ sum (- size index)))) 0 (range size)))

(defn transpose [input]
  (apply mapv vector input))

(defn solution-1 [input]
  (let [size (count input)]
    (->> input
         transpose
         (map move-north)
         (map (partial count-load size))
         (reduce + 0))))

(solution-1 input)

(defn tilt-90 [input]
  (into [] (reverse (transpose input))))

(defn tilt-minus-90 [input]
  (mapv #(into [] (reverse %)) (transpose input)))

(def tilt (partial mapv move-north))

(def tilt-north (comp tilt-minus-90 tilt tilt-90))
(def tilt-west tilt)
(def tilt-south (comp tilt-90 tilt tilt-minus-90))
(def tilt-east (comp tilt-90 tilt-south tilt-minus-90))

(def spin-and-tilt (comp tilt-east tilt-south tilt-west tilt-north))

(defn detect-cycle [input]
  (let [size (count input)]
    (loop [input input id 0 path [] seen {}]
      (if (seen input)
        {:path path
         :visited id
         :cycle-len (- id (seen input))
         :first (seen input)}
        (let [next-input (spin-and-tilt input)]
          (recur next-input
                 (inc id)
                 (conj path input)
                 (conj seen [input id])))))))

(defn solution-2 [input]
  (let [cycle (detect-cycle input)
        cycle-len (:cycle-len cycle)
        remaining (- 1000000000 (:visited cycle))
        solution-id (+ (:first cycle) (mod remaining cycle-len))]
    (->> (nth (:path cycle) solution-id)
         transpose
         (map (partial count-load 100))
         (reduce + 0))))

(solution-2 input)
