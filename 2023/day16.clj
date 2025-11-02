(ns aoc.day16
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(def input
  (->> "resources/day16.txt"
       io/reader
       line-seq
       (mapv #(into [] %))))

(def sample
  (->> "resources/day16-sample.txt"
       io/reader
       line-seq
       (mapv #(into [] %))))

(def directions-offsets {:up [-1 0] :down [1 0] :left [0 -1] :right [0 1]})

(def reflections {\| {:up :up, :down :down, :left :split, :right :split}
                  \- {:up :split, :down :split, :left :left, :right :right}
                  \\ {:up :left, :down :right, :left :up, :right :down}
                  \/ {:up :right, :down :left, :left :down, :right :up}
                  \# {:up :up, :down :down, :left :left, :right :right}
                  \. {:up :up, :down :down, :left :left, :right :right}})

(defn walk [pos dir]
  (mapv + pos (directions-offsets dir)))

(defn dot? [c]
  (= \. c))

(defn valid-builder [grid]
  (let [row-size (count grid) col-size (count (first grid))]
    (fn [[row col]]
      (and (< -1 row row-size)
           (< -1 col col-size)))))

(defn after-split [dir]
  (case dir
    :up [:left :right]
    :down [:left :right]
    :left [:down :up]
    :right [:down :up]))

(defn next-pos [grid pos dir]
  (let [tile (get-in grid pos)
        reflection (get-in reflections [tile dir])
        splits (after-split dir)]
    (if (= :split reflection)
      [{:pos pos :dir (first splits)} {:pos pos :dir (second splits)}]
      [{:pos pos :dir reflection}])))

(defn dfs [grid [start dir]]
  (let [valid? (valid-builder grid)
        next-pos (partial next-pos grid)]
    (loop [[peek & pop :as stack] [{:pos start :dir dir}] visited #{} energized #{}]
      (if (empty? stack)
        energized
        (let [dir' (:dir peek) pos' (walk (:pos peek) dir')]
          (if (and (valid? pos') (not (visited [pos' dir'])))
            (recur (into pop (next-pos pos' dir')) (conj visited [pos' dir']) (conj energized pos'))
            (recur pop visited energized)))))))

(defn solution-1 [input]
  (count (dfs input [[0 -1] :right])))

(solution-1 sample)

(solution-1 input)

(defn get-starting-pos [grid]
  (let [row (dec (count grid))
        col (dec (count (first grid)))]
    (concat [[[0 0] :down] [[0 0] :right]]
            [[[0 col] :down] [[0 col] :left]]
            [[[row 0] :up] [[row 0] :right]]
            [[[row col] :up] [[row col] :left]]
            (for [i (range 1 col)]
              [[0 i] :down])
            (for [i (range 1 col)]
              [[row i] :up])
            (for [i (range 1 row)]
              [[i col] :left])
            (for [i (range 1 row)]
              [[i 0] :right]))))

(defn solution-2 [grid]
  (let [dfs (partial dfs grid)]
    (->> grid
         get-starting-pos
         (map (comp count dfs))
         (apply max))))

(solution-2 sample)

(solution-2 input)
