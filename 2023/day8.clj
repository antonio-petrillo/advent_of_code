(ns aoc.day8
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(def input
  (s/split (->> "resources/day8.txt"
       io/reader
       slurp) #"\n\n"))

(def directions (cycle (seq (first input))))

(defn parse-map [line]
  (let [[pos left right] (re-seq #"\w+" line)]
    {pos {\L left \R right}}))

(def mapping
  (reduce (fn [readed line] (into readed (parse-map line)))
          {}
          (s/split-lines (second input))))

(defn walk [arrived? [pos steps] move]
  (if (arrived? pos)
    (reduced steps)
    [(get-in mapping [pos move]) (inc steps)]))

(defn solution-1 [end-condition start-from]
  (reduce (partial walk end-condition) [start-from 0] directions))

(solution-1 #(= % "ZZZ") "AAA") ;; => 19199

(time (solution-1 #(= % "ZZZ")  "AAA"))
;; Elapsed time: 10.549208 msecs

(def a-positions (for [[k _] mapping
                      :when (= \A (last k))]
                      k))

(def z-positions (for [[k _] mapping
                      :when (= \Z (last k))]
                      k))

(defn all-in-Z? [positions]
  (apply (partial = \Z) (map last positions)))

(defn brute-force-solution-2 []
  (second (reduce
           (fn [[positions steps] direction]
             (if (all-in-Z? positions)
               (reduced steps)
               [(map #(get-in mapping [% direction]) positions) (inc steps)]))
           [a-positions 0]
           directions)))

#_(brute-force-solution-2) ;; => out of memory

(defn get-mapping [pos]
  (-> #{}
       (conj (get-in mapping [pos \L]))
       (conj (get-in mapping [pos \R]))))

(defn check-assumptions []
  (let [ next-to-a (reduce (fn [s pos] (into s (get-mapping pos))) #{} a-positions)
        next-to-z (reduce (fn [s pos] (into s (get-mapping pos))) #{} a-positions)]
    (empty? (set/difference next-to-a next-to-z))))

(check-assumptions) ;; => true
;; cycles have all the same length of paths from XXA to YYZ

(defn gcd [a b]
  (loop [a (abs a) b (abs b)]
    (if (zero? b)
      a
      (recur b (mod a b)))))

(defn lcm [a b]
  (let [a (abs a) b (abs b)]
    (quot (* a b) (gcd a b))))

;; exploit that cycle start from pos next from "XXA" of seq
(defn solution-2 []
  (let [cycle-lens (map (partial solution-1 #(= \Z (last %))) a-positions)]
    (reduce #(lcm %1 %2) 1 cycle-lens)))

(solution-2)

(time (solution-2))
