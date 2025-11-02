(ns day1
  (:require [clojure.java.io :as io]))

(def str->digits
  {"one" 1 "1" 1
   "two" 2 "2" 2
   "three" 3 "3" 3
   "four" 4 "4" 4
   "five" 5 "5" 5
   "six" 6 "6" 6
   "seven" 7 "7" 7
   "eight" 8 "8" 8
   "nine" 9 "9" 9})

(defn read-digit [s]
  (str->digits s))

(defn parse-line [regex s]
  (let [regex-start (re-pattern (str "(" regex ").*$"))
        regex-end (re-pattern (str "^.*(" regex ")"))
        first (->> s
                  (re-find regex-start)
                  second
                  read-digit)
        last (->> s
                  (re-find regex-end)
                  second
                  read-digit)]
    (+ (* 10 first) last)))

(defn solution [regex]
  (let [input (->> "resources/day-1.txt"
                   io/reader)
        parse-line (partial parse-line regex)]
    (with-open [reader input]
      (reduce (fn [result line]
                ((partial + result) (parse-line line)))
              0 (line-seq reader)))))

(solution "[1-9]")
(solution "[1-9]|one|two|three|four|five|six|seven|eight|nine")
