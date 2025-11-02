(ns aoc-2024.day9
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(defn expand-disk [disk]
  (let [size (count disk)]
    (loop [exp [] i 0 file-id 0]
      (cond
        (= i size) exp
        (even? i) (recur (reduce conj exp (repeat (disk i) file-id)) (inc i) (inc file-id))
        :else (recur (reduce conj exp (repeat (disk i) :space)) (inc i) file-id)))))

(def disk
  (->> "resources/day9.txt"
       slurp
       (re-seq #"\d")
       (map parse-long)
       vec
       expand-disk))

(def disk-ex
  (->> "resources/day9ex.txt"
       slurp
       (re-seq #"\d")
       (map parse-long)
       vec
       expand-disk))

(defn compact [disk]
  (loop [start 0 last (dec (count disk)) compacted disk]
    (if (>= start last)
      (take (count (remove #(= :space %) disk))  compacted)
      (case (disk start)
        :space (let [last-non-space
                     (loop [last last] (if (not= :space (disk last)) last (recur (dec last))))]
                 (recur (inc start) (dec last-non-space) (assoc compacted start (disk last-non-space))))
        (recur (inc start) last compacted)))))

(defn checksum [compacted]
  (->> compacted
       (map (fn [i v] (if (= :space v) 0 (* i v))) (range))
       (reduce + 0)))

(defn part-1 [disk]
  (->> disk
       compact
       checksum))

(part-1 disk-ex)
(part-1 disk)

(defn indexes-disk [disk]
  (loop [[p & ps] (partition-by identity disk) i 0 out []]
    (if (nil? p)
      (let [{:keys [spaces frag]} (group-by (fn [[_ [v & _]]] (if (= :space v) :spaces :frag)) out)]
        { :spaces (map (fn [[k v]] [k (count v)]) spaces)
          :frags (->> frag (into (sorted-map))) })
      (recur ps (+ i (count p)) (conj out [i p])))))

(defn next-fitting-frag [frags [idx available-space ]]
  (first (for [[id data :as frag] (reverse frags)
               :when (and (<= (count data) available-space)
                          (> id idx))]
    frag)))

(defn defrag [{:keys [spaces frags]}]
  (let [[k v] (first frags)]
  (loop [out (sorted-map k v) frags (dissoc frags k) [[idx avail-space :as space] & more-spaces] spaces]
    (if (nil? space)
      (reduce conj out frags)
      (let [next-fit (next-fitting-frag frags space)]
        (if (nil? next-fit)
          (recur out frags more-spaces)

          (let [[id data] next-fit size (count data)]
            (if (= size avail-space)
              (recur (assoc out idx data) (dissoc frags id) more-spaces)
              (recur (assoc out idx data) (dissoc frags id) (cons [(+ idx size) (- avail-space size)] more-spaces))))))))))

(defn checksum-2 [defragged]
  (->> defragged
      (mapcat (fn [[start vals]] (map * vals (iterate inc start))))
      (reduce + 0)))

(defn part-2 [disk]
  (->> disk
       indexes-disk
       defrag
       checksum-2))

(part-2 disk-ex)
(part-2 disk)
