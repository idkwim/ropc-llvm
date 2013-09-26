open Batteries
open Printf

module ISet = Set.Make(struct
                         type t = int
                         let compare (x : int) y =
                           if x > y then 1 else if x < y then -1 else 0
                       end)
module IMap = Map.IntMap

module G = struct
    
  module SetMap = struct
    type t = ISet.t IMap.t
    let find i t =   
      try IMap.find i t
      with Not_found -> ISet.empty
    let add i j t =
      IMap.add i (ISet.add j (find i t)) t
    let del i j t = 
      let s = ISet.remove j (find i t) in
      if ISet.is_empty s then IMap.remove i t
      else IMap.add i s t
    let del_check i j t = 
      let s = ISet.remove j (find i t) in
      if ISet.is_empty s then raise Not_found
      else IMap.add i s t
    let empty = IMap.empty
  end
    
  type t = { i: SetMap.t; o: SetMap.t }

  let empty = { i = SetMap.empty; o = SetMap.empty }

  let nodes g = IMap.keys g.o 
  let nodes_in g = IMap.keys g.i

  let list_of_iset s = ISet.fold (fun i a -> i :: a) s []

  let nbrs_set g n = SetMap.find n g.o
  let in_nbrs_set g n = SetMap.find n g.i

  let fold_out g f v = IMap.fold f g.o v
  let fold_in g f v = IMap.fold f g.i v

  let get g i j = SetMap.find i g.o |> ISet.mem j 
      
  let print_set i s = 
    printf "%d) " i;
    ISet.print ~first:"{" ~sep:" " ~last:"}\n" Int.print stdout s

  let print g =   
    printf "Out:\n"; IMap.iter print_set g.o;
    printf "In:\n"; IMap.iter print_set g.i

  let is_empty g = IMap.is_empty g.i
  let choose g = let (x,_) = IMap.choose g.o in x

  let add g x y = {o = SetMap.add x y g.o; i = SetMap.add y x g.i}

  let add_undir g x y = add (add g y x) x y


  let remove_out_ok g i =
    let nbrs = SetMap.find i g.o in
    { o = IMap.remove i g.o; 
      i = ISet.fold (fun j a -> SetMap.del j i a) nbrs g.i }
end

let reduce_all g = 
  let reduce_i i iset g =
    (* TODO: rewrite without enum *)
    let doms = ISet.enum iset |> Enum.map (G.in_nbrs_set g) in
    let rec loop acc = 
      if ISet.is_empty acc then g else
	match Enum.get doms with
	    None -> G.remove_out_ok g i
	  | Some ns -> loop (ISet.inter acc ns)
    in
    match Enum.get doms with 
	None -> assert false 
      | Some ns -> loop (ISet.remove i ns)
  in
  G.fold_out g reduce_i g

let data = "100
900
3 0
5 4
6 3
7 1
8 0
8 4
8 5
9 6
10 5
11 2
11 4
11 6
11 10
12 3
12 6
12 10
13 5
13 7
13 8
13 12
14 6
14 12
14 13
15 3
15 8
15 9
15 11
16 1
16 2
16 3
17 1
17 6
17 16
18 0
18 1
18 5
19 14
20 2
20 6
20 9
20 10
20 16
20 17
21 4
21 6
21 11
21 17
23 8
23 11
23 16
23 20
24 2
24 20
25 5
25 6
25 18
26 0
26 7
26 10
26 11
26 12
26 18
26 25
27 0
27 3
27 4
27 15
27 24
27 26
28 0
28 11
28 17
28 19
28 21
29 1
29 7
29 17
29 24
30 5
30 7
30 16
30 20
30 23
30 28
30 29
31 2
31 4
31 12
31 17
31 22
31 27
32 5
32 8
32 22
32 29
33 2
33 10
33 16
33 22
33 23
33 25
34 3
34 10
34 11
34 17
34 18
34 20
34 28
34 31
35 1
35 17
35 19
35 29
35 30
36 0
36 15
36 24
36 25
36 26
36 27
36 33
36 35
37 3
37 8
37 14
37 16
37 18
37 28
37 30
37 33
38 5
38 7
38 18
38 31
39 10
39 12
39 14
39 18
39 30
39 34
39 36
40 2
40 12
40 22
40 30
41 13
41 26
41 27
41 29
42 2
42 3
42 4
42 7
42 12
42 15
42 24
42 36
42 37
42 38
43 9
43 22
43 33
43 39
43 42
44 2
44 7
44 11
44 13
44 16
44 17
44 22
44 24
44 29
44 34
44 37
45 0
45 1
45 4
45 7
45 9
45 10
45 11
45 27
45 28
45 37
46 6
46 7
46 8
46 13
46 18
46 19
46 21
46 22
46 31
46 40
46 41
46 43
47 3
47 9
47 10
47 11
47 23
47 29
47 39
48 4
48 19
48 20
48 23
48 25
48 29
48 32
48 33
48 45
48 47
49 4
49 13
49 14
49 25
49 31
49 32
49 44
49 46
50 2
50 8
50 21
50 22
50 23
50 29
50 43
50 45
50 47
50 48
51 5
51 9
51 10
51 11
51 14
51 18
51 22
51 24
51 25
51 27
51 28
51 34
51 36
51 37
51 40
51 46
52 11
52 14
52 22
52 32
52 41
52 45
52 47
53 4
53 6
53 13
53 21
53 22
53 26
53 32
53 34
53 37
53 39
53 45
54 11
54 15
54 17
54 19
54 22
54 30
54 36
54 41
54 43
54 44
54 51
55 13
55 23
55 30
55 32
55 46
56 1
56 6
56 12
56 14
56 16
56 17
56 22
56 38
56 42
56 49
57 5
57 9
57 10
57 11
57 12
57 16
57 24
57 38
57 41
57 43
57 48
58 1
58 7
58 11
58 13
58 21
58 23
58 33
58 34
58 39
58 40
58 42
58 45
58 48
58 54
58 55
59 9
59 16
59 43
59 46
59 49
59 53
60 10
60 17
60 20
60 25
60 32
60 39
60 41
60 42
60 43
60 49
61 5
61 21
61 27
61 29
61 44
61 45
61 48
61 49
61 51
61 55
61 56
61 57
61 60
62 3
62 4
62 14
62 21
62 29
62 38
62 47
62 52
63 8
63 16
63 20
63 22
63 23
63 25
63 26
63 29
63 30
63 31
63 41
63 47
63 53
64 16
64 19
64 20
64 24
64 28
64 49
64 52
64 55
64 61
65 2
65 10
65 16
65 18
65 21
65 22
65 23
65 25
65 26
65 29
65 33
65 36
65 55
65 60
65 63
66 0
66 12
66 32
66 45
67 12
67 16
67 17
67 20
67 22
67 23
67 27
67 31
67 38
67 44
67 47
67 56
67 60
67 62
67 64
68 14
68 18
68 19
68 21
68 29
68 30
68 34
68 44
68 49
68 52
68 63
68 64
69 0
69 7
69 9
69 13
69 14
69 16
69 17
69 21
69 32
69 34
69 41
69 43
69 54
69 61
69 62
69 64
70 7
70 18
70 33
70 46
70 47
70 48
70 61
70 62
71 4
71 18
71 21
71 29
71 44
71 45
71 50
71 51
71 58
71 63
71 65
72 3
72 18
72 27
72 28
72 31
72 32
72 39
72 41
72 43
72 44
72 66
73 12
73 19
73 24
73 29
73 31
73 32
73 36
73 40
73 45
73 51
73 55
73 58
73 64
73 71
74 5
74 6
74 8
74 12
74 15
74 31
74 36
74 39
74 41
74 42
74 43
74 53
74 58
74 64
75 2
75 4
75 6
75 10
75 17
75 26
75 30
75 34
75 35
75 37
75 59
75 65
75 70
75 72
76 8
76 10
76 11
76 12
76 20
76 34
76 46
76 49
76 51
76 52
76 53
76 55
76 58
76 67
76 69
76 70
76 72
77 17
77 24
77 32
77 35
77 39
77 43
77 46
77 48
77 51
77 52
77 54
77 55
77 75
78 4
78 5
78 9
78 12
78 20
78 21
78 23
78 26
78 27
78 48
78 53
78 55
78 60
78 61
78 64
78 70
79 2
79 3
79 9
79 32
79 35
79 37
79 40
79 44
79 48
79 50
79 52
79 53
79 54
79 65
79 66
79 68
79 73
80 10
80 14
80 23
80 30
80 44
80 49
80 53
80 66
80 70
80 73
81 0
81 4
81 10
81 12
81 14
81 24
81 27
81 33
81 39
81 47
81 64
81 69
81 73
82 2
82 6
82 10
82 11
82 13
82 36
82 38
82 40
82 42
82 51
82 52
82 53
82 69
82 70
82 74
83 10
83 15
83 20
83 26
83 28
83 43
83 48
83 50
83 53
83 57
83 64
83 65
83 71
84 5
84 16
84 25
84 29
84 34
84 37
84 41
84 42
84 43
84 51
84 54
84 57
84 58
84 64
84 67
84 71
84 73
84 77
84 79
84 82
85 7
85 11
85 15
85 17
85 22
85 23
85 32
85 34
85 41
85 42
85 43
85 54
85 61
85 66
85 74
85 81
86 10
86 13
86 23
86 24
86 36
86 39
86 44
86 51
86 58
86 60
86 61
86 64
86 65
86 67
86 70
86 75
87 15
87 19
87 26
87 30
87 33
87 38
87 45
87 59
87 71
87 72
87 73
87 74
87 81
87 82
87 85
88 10
88 20
88 23
88 24
88 27
88 29
88 46
88 62
88 64
88 76
88 77
88 78
88 86
89 2
89 8
89 10
89 17
89 24
89 25
89 33
89 35
89 37
89 42
89 50
89 51
89 53
89 61
89 67
89 74
89 76
89 77
89 83
89 87
90 10
90 11
90 21
90 25
90 28
90 37
90 50
90 53
90 56
90 59
90 61
90 62
90 63
90 66
90 74
90 83
90 87
91 4
91 6
91 8
91 9
91 10
91 19
91 21
91 23
91 29
91 40
91 42
91 63
91 68
91 72
91 78
91 85
92 17
92 19
92 30
92 32
92 36
92 38
92 58
92 62
92 65
93 0
93 1
93 5
93 14
93 16
93 24
93 25
93 37
93 42
93 47
93 56
93 63
93 65
93 71
93 78
93 85
93 86
93 92
94 9
94 10
94 12
94 28
94 30
94 37
94 41
94 48
94 55
94 57
94 61
94 64
94 65
94 66
94 67
94 73
94 77
94 83
95 0
95 6
95 8
95 10
95 13
95 14
95 15
95 16
95 31
95 36
95 39
95 55
95 56
95 69
95 70
95 76
95 77
95 86
95 91
96 1
96 8
96 16
96 19
96 33
96 34
96 45
96 57
96 66
96 76
96 81
96 88
97 6
97 10
97 17
97 32
97 38
97 40
97 43
97 51
97 52
97 54
97 60
97 62
97 64
97 66
97 68
97 70
97 77
97 79
97 83
97 88
97 91
98 2
98 5
98 13
98 14
98 23
98 27
98 28
98 32
98 33
98 36
98 42
98 46
98 49
98 50
98 51
98 56
98 57
98 60
98 62
98 75
98 78
98 79
98 80
98 81
98 83
98 84
98 90
98 92
99 1
99 2
99 6
99 9
99 16
99 22
99 23
99 33
99 41
99 45
99 49
99 71
99 75
99 85
99 86
99 91
99 97
"

let () =
  let in_f = Scanf.Scanning.from_string data in
  let n = Scanf.bscanf in_f "%d " identity in
  let full_g = ref G.empty in
  (* read the input file and produce full_g *)
  let read_edges n = 
    for i = 1 to n do
      Scanf.bscanf in_f "%d %d " (fun x y -> full_g := G.add_undir !full_g x y)
    done
  in
  Scanf.bscanf in_f "%d " read_edges;

  (* extend the graph with loops and reduce *)
  let dg = fold (fun g i -> G.add g i i) !full_g (0--(n-1)) in  
  let t0 = Sys.time () in
  for i = 1 to 1000 do
    ignore (reduce_all dg);
  done;
  printf "Time taken: %.3fs\n" (Sys.time () -. t0)
