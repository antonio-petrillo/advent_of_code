(ns aoc-2024.day15
  (:require [clojure.java.io :as io]
            [clojure.string :as s]
            [clojure.set :as set]))

(def input
  (let [[map-str moves] (-> "resources/day15.txt"
                           slurp
                           (s/split #"\n\n"))]
    {:deposit (->> map-str
                s/split-lines
                (map vec)
                (into []))
      :moves (->> moves s/split-lines (s/join "") vec)}))

(def deltas
  {\^ [-1 0]
   \v [1 0]
   \> [0 1]
   \< [0 -1]})

(defn find-next-free-spot [deposit pos move]
  (let [delta (deltas move)]
    (loop [p (mapv + pos delta)]
      (case (get-in deposit p)
        \# :none
        \. p
        \O (recur (mapv + p delta))))))

(defn shift-boxes-and-robot [deposit robot-pos next-robot-pos move]
  (let [next-free-spot (find-next-free-spot deposit next-robot-pos move)]
    (if (= :none next-free-spot)
      [robot-pos deposit] ;; no-op, no free space
      [next-robot-pos
       (-> deposit
           (assoc-in next-free-spot \O)
           (assoc-in next-robot-pos \.))])))

(defn move-robot [pos deposit move]
  (let [next-robot-pos (mapv + pos (deltas move))]
    (case (get-in deposit next-robot-pos)
      \# [pos deposit] ;; no op
      \. [next-robot-pos deposit] ;; move robot
      \O (shift-boxes-and-robot deposit pos next-robot-pos move))))

(defn get-start-pos [deposit]
  (reduce #(reduced %2)  nil (for [i (range (count deposit)) j (range (count (first deposit)))
                 :when (= \@ (get-in deposit [i j]))]
           [i j])))

(defn arrange [{:keys [deposit moves]}]
  (loop [pos (get-start-pos deposit)
         dep (assoc-in deposit pos \.)
         [m & ms] moves]
    (if (nil? m)
      dep
      (let [[p d] (move-robot pos dep m)]
        (recur p d ms)))))

(defn gps-checksum [deposit]
  (->> deposit
       (map-indexed (fn [i row]
                      (map-indexed #(if (= \O %2) (+ (* i 100) %1) 0) row)))
       (apply concat)
       (reduce + 0)))

(defn part-1 [input]
  (gps-checksum (arrange input)))

(part-1 input)

(def expansion
  {\# '(\# \#)
   \. '(\. \.)
   \@ '(\@ \.)
   \O '(\[ \])})

(defn expand-deposit [deposit]
  (mapv #(vec (mapcat expansion %)) deposit))

(defn find-boxes-to-shift [deposit robot-pos move]
  (let [delta (deltas move)]
    (loop [q (conj clojure.lang.PersistentQueue/EMPTY robot-pos) to-update '() seen #{robot-pos}]
      (if (empty? q)
        to-update
        (let [[r c :as n-pos] (mapv + delta (peek q)) qs (pop q)
              left [r (dec c)] right [r (inc c)]]
          (if (seen n-pos)
            (recur qs to-update seen)
            (case (get-in deposit n-pos)
              \. (recur qs to-update (conj seen n-pos))
              \[ (recur (reduce conj qs [n-pos right])
                        (reduce conj to-update [[n-pos \[] [right \]]])
                        (reduce conj seen [n-pos right]))
              \] (recur (reduce conj qs [n-pos left])
                        (reduce conj to-update [[n-pos \]] [left \[]])
                        (reduce conj seen [n-pos left]))
              \# :none)))))))

(defn shift-part [delta deposit [pos type]]
  (-> deposit
      (assoc-in pos \.)
      (assoc-in (mapv + pos delta) type)))

(defn arrange-2 [{:keys [deposit moves]}]
  (let [deposit (expand-deposit deposit)
        start (get-start-pos deposit)]
   (loop [deposit (assoc-in deposit start \.) pos start [move & moves] moves]
      (if (nil? move)
        deposit
        (let [to-shift (find-boxes-to-shift deposit pos move) delta (deltas move)]
          (if (= :none to-shift)
            (recur deposit pos moves)
            (recur
             (reduce (partial shift-part delta) deposit to-shift)
             (mapv + pos delta)
             moves)))))))

(defn gps-checksum-2 [deposit]
  (->> deposit
       (map-indexed (fn [i row]
                      (map-indexed #(if (= \[ %2) (+ (* i 100) %1) 0) row)))
       (apply concat)
       (reduce + 0)))

(defn part-2 [input]
  (->> input
       arrange-2
       gps-checksum-2))

(part-2 input)
