(ns aoc.day15
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(def input
  (s/split (->> "resources/day15.txt"
                io/reader
                slurp
                seq
                butlast
                (apply str))
           #","))

(defn HASH [s]
  (reduce (fn [hash c] (-> c
                          int
                          (+ hash)
                          (* 17)
                          (mod 256)))
          0 s))

(defn solution-1 [input]
  (->> input
       (map HASH)
       (reduce + 0)))

(def sample (s/split "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7" #","))

(solution-1 sample)

(solution-1 input)

(defn parse-instr [to-parse]
  (let [[label op id] (rest (re-find #"([^0-9\-=]+)([\-=])([0-9]?)" to-parse))]
    (if (empty? id)
      {:label label :op op :hash (HASH label) :id nil}
      {:label label :op op :hash (HASH label) :id (parse-long id)})))

(defn read-instructions [input]
  (map parse-instr input))

(defn apply-instr [box {:keys [label id op]} ids]
  (case op
    "-" (dissoc box label)
    "=" (if (box label)
          (assoc-in box [label :id] id)
          (let [_ (swap! ids inc)]
            (assoc box label {:id id :order @ids})))))

;; search why transducers mess up the `count`
(defn apply-instrs [instructions]
  (let [ids (atom 0)]
    (loop [boxes (zipmap (range 256) (repeat {})) [instr & instructions] instructions]
      (if (nil? instr)
        boxes
        (let [hash-id (:hash instr)
              box (boxes hash-id)
              updated (apply-instr box instr ids)]
          (recur (assoc boxes hash-id updated) instructions))))))

(def slots (take 9 (range 1 10)))

(defn box->focus-power [hash box]
  (let [ids (map (comp :id second) (sort-by :order box))]
    (reduce + 0 (map #(* (inc hash) %1 %2) ids slots))))

(defn all-box-focus [boxes]
  (for [[hash box] boxes]
    (box->focus-power hash box)))

(defn solution-2 [input]
  (->> input
       read-instructions
       apply-instrs
       all-box-focus
       (reduce + 0)))

(solution-2 sample)

(solution-2 input)
