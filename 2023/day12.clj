(ns aoc.day12
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as s]))

(def input
  (->> "resources/day12.txt"
       io/reader
       line-seq))

(def sample
  ["???.### 1,1,3"
   ".??..??...?##. 1,1,3"
   "?#?#?#?#?#?#?#? 1,3,1,6"
   "????.#...#... 4,1,1"
   "????.######..#####. 1,6,5"
   "?###???????? 3,2,1"])

(defn parse-line[line]
  (let [parts (re-find #"[\?\.#]+" line)
        nums (map parse-long (re-seq #"\d+" line))]
    [parts nums]))

(defn count-config [[part & rem-parts :as parts] [num & rem-nums :as nums]]
  (cond (empty? parts) (if (empty? nums) 1 0) ;; no more parts -> check if that the there aren't any more numbers
        (empty? nums) (reduce #(if (= \# %2) (reduced 0) 1) 1 parts) ;; when no more nums check that there are no more \#
        :else (let [enough-space? (<= num (count parts)) ;; next piece will fits in the remaining parts?
                    valid-subsequence? (every? #{\? \#} (take num parts)) ;; the first `num` parts are composed only by \? an \#
                    followed-by-broken (or (= num (count parts)) ;; if the part fits check that the next is not a broken one (between series of broken there must be a working one)
                            (not= \# (first (drop num parts))))]
                (+ (if (#{\? \.} part) (count-config rem-parts nums) 0) ;; sum the subsequence without the trailing \? and \. (if start with one of them)
                   (if (and enough-space? valid-subsequence? followed-by-broken) ;; if the subpart fit, it is valid and is not followe by \#
                     (count-config (drop (inc num) parts) rem-nums) ;; count the remaining
                     0))))) ;; backtrack, from here on there are no more combination to check

(defn solution-1 [input]
  (->> input
       (map parse-line)
       (map (partial apply count-config))
       (reduce + 0)))

(solution-1 sample)
(solution-1 input)

(defn unfold
  "This one is extremely inefficient, but I managed to write it in less that 10 seconds"
  [[parts nums]]
  [(->> parts
        (apply str)
        (repeat 5)
        (interpose "?")
        (apply str)
        seq)
   (apply concat (repeat 5 nums))])

(defn cached-count-config
  "TODO: check why (memoize count-config) doesn't work in this case, more generally memoize with recursive function"
  ([cache [part & rem-parts :as parts] [num & rem-nums :as nums]]
  (cond (@cache (vector parts nums)) (@cache (vector parts nums)) ;; check if in cache
        (empty? parts) (if (empty? nums) 1 0)
        (empty? nums) (reduce #(if (= \# %2) (reduced 0) 1) 1 parts)
        :else (let [enough-space? (<= num (count parts))
                    valid-subsequence? (every? #{\? \#} (take num parts))
                    followed-by-broken? (or (= num (count parts))
                                            (not= \# (first (drop num parts))))
                    sum (+ (if (#{\? \.} part) (cached-count-config cache rem-parts nums) 0)
                           (if (and enough-space? valid-subsequence? followed-by-broken?)
                             (cached-count-config cache (drop (inc num) parts) rem-nums)
                             0))
                    _ (swap! cache conj  [(list parts nums) sum])] ;; add to cache, ugly but it works
                sum))
   ([parts nums]
    (cached-count-config parts nums (atom {}))))) ;; use with default cache

(def cache
  "non default cache, used to see the difference between two successive computations"
  (atom {}))

(defn solution-2 [input]
  (->> input
       (map parse-line)
       (map unfold)
       (map (partial apply cached-count-config cache))
       (reduce + 0)))

(defn solution-2-parallel
  "just parallelize with pmap, could be done better with an executor"
  [input]
  (->> input
       (map parse-line)
       (map unfold)
       (pmap (partial apply cached-count-config cache))
       (reduce + 0)))

@cache ;; just to check cache status

(solution-2 sample)
(solution-2 input)

(time (solution-2 input))
;; Elapsed time: 2408.326667 msecs, start with empty cache
;; Elapsed time: 36.478125 msecs, with full cache

(time (solution-2-parallel input))
;; Elapsed time: 1007.265458 msecs, start with empty cache
;; Elapsed time: 12.47925 msecs, with full cache

;; Can be futher improved by adjusting unfold and other small pieces.
