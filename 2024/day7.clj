(ns aoc-2024.day7
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(def input
  (->> "resources/day7.txt"
       io/reader
       line-seq
       (map (partial re-seq #"\d+"))
       (map #(map parse-long %))))

(def input-ex
  (->> "resources/day7ex.txt"
       io/reader
       line-seq
       (map (partial re-seq #"\d+"))
       (map #(map parse-long %))))

(defn valid?
  ([fns target [n1 n2 & ns]]
   (if (nil? n2)
     (= target n1)
     (->> fns
          (map #(% n1 n2))
          (map #(cons % ns))
          (some (partial valid? fns target)))))
  ([fns equation]
   (valid? fns (first equation) (rest equation))))

(defn part-1 [data]
  (->> data
       (filter (partial valid? [+ *]))
       (map first)
       (reduce + 0)))

(part-1 input)
(part-1 input-ex)

(defn part-2 [data]
  (->> data
       (filter (partial valid? [+ * #(parse-long (str %1 %2))]))
       (map first)
       (reduce + 0)))

(part-2 input)
(part-2 input-ex)
