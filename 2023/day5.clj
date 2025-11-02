(ns aoc.day5
  (:require [clojure.java.io :as io]
            [clojure.string :as s]))

(defn input []
  (->> "resources/day5.txt"
       io/reader
       line-seq))

(defn parse-seeds [first-line]
  (let [ids (re-seq #"\d+" first-line)]
    (mapv #(Long/parseLong %) ids)))

(defn singleton [root]
 [nil root nil])

(defn insert
  ([node] (singleton node))
  ([node [left root right :as tree]]
   (let [[new-low new-high] (:range node)
         [low high] (:range root)]
     (cond (nil? tree) (singleton node)
           (< new-high low) [(insert node left) root right]
           (> new-low high) [left root (insert node right)]
           :else (throw (IllegalArgumentException. "Overlapping sequences"))))))

(defn get-mapping-in-range [id [left root right :as tree]]
  (let [[low high] (:range root)]
    (cond (nil? tree) id
          (<= low id high) (+ (first (:mapping root)) (- id low))
          (< id low) (get-mapping-in-range id left)
          (> id high) (get-mapping-in-range id right))))

(defn parse-header [header]
  (->> header
       (re-find #"\w+-\w+-\w+")
       keyword))

(defn parse-data-line [line]
  (let [[s-dest s-source s-span] (s/split line #" +")
        dest (Long/parseLong s-dest)
        source (Long/parseLong s-source)
        span (dec (Long/parseLong s-span))]
    {:range [source (+ source span)] :mapping [dest (+ dest span)] :span span}))

(defn parse-data [data]
  (let [nodes (map parse-data-line data)]
    (reduce (fn [tree node]
              (if (nil? tree)
                (insert node)
                (insert node tree))) nil nodes)))

(defn parse-map [[header & data]]
  [(parse-header header) (parse-data data)])

(defn parse-maps [input]
  (loop [lines input parsed {}]
    (if (empty? lines)
      parsed
      (let [[map-data lines] (split-with (complement empty?) lines)]
        (recur (rest lines) (conj parsed (parse-map map-data)))))))

(defn parse-input []
  (let [input (input)
        seeds (parse-seeds (first input))
        data (drop 2 input)]
    {:seeds seeds :tree (parse-maps data)}))

(def steps
  [:seed-to-soil
   :soil-to-fertilizer
   :fertilizer-to-water
   :water-to-light
   :light-to-temperature
   :temperature-to-humidity
   :humidity-to-location])

(defn soil->location
  ([tree seed steps]
   (reduce
    (fn [id step]
      (get-mapping-in-range id (step tree)))
    seed
    steps))
  ([tree seed]
   (soil->location tree seed steps)))

(defn solution-1 []
  (let [parsed (parse-input)
        tree (:tree parsed)
        seeds (:seeds parsed)]
    (apply min (map (partial soil->location tree) seeds))))

(solution-1)

(defn get-next-range-walk-tree [[left root right :as tree] [start end :as seeds]]
  (let [[begin finish] (:range root)
        [l h] (:mapping root)
        offset (:span root)]
    (cond
      (nil? tree) [[start end]]
      (<= begin start end finish) [[(+ offset start) (+ offset end)]]
      (< end begin) (get-next-range-walk-tree left seeds)
      (> start finish) (get-next-range-walk-tree right seeds)
      (<= start begin end finish) (into [[l (+ l (- end begin))]]
                                        (get-next-range-walk-tree left [start (dec begin)]))
      (<= begin start finish end) (into [[(+ l (- start begin)) h]]
                                        (get-next-range-walk-tree right [(inc finish) end]))
      (<= start begin finish end) (-> [[l h]]
                                       (into (get-next-range-walk-tree right [start (dec begin)]))
                                       (into (get-next-range-walk-tree left [(inc finish) end]))))))

(defn reduce-trees [trees seeds]
  (loop [[step & steps] steps seeds seeds]
    (if (nil? step)
      seeds
      (recur steps (mapcat (partial get-next-range-walk-tree (step trees)) seeds)))))

(defn solution-2 []
  (let [parsed (parse-input)
        trees (:tree parsed)
        seeds (->> (:seeds parsed)
                   (partition 2 2)
                   (map (fn [[start offset]] [start (+ start (dec offset))])))]
    (->> (reduce-trees trees seeds)
         (map first)
         (apply min))))

;; time 1 millisecond
(solution-2)

(defn solution-2-brute-force []
  (let [parsed (parse-input)
        tree (:tree parsed)
        seeds (->> (:seeds parsed) (partition 2 2)
                   (mapcat (fn [[start offset]] (range start (+ start offset)))))]
    (apply min (pmap (partial soil->location tree) seeds))))

;; time 3h 53min
(solution-2-brute-force)
