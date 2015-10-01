import UIKit


/*:
# LCS - Longest Common Subsequence

http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
*/
func LCS(X: String, _ Y: String) -> [String]
{
/*:
We turn the strings into arrays because it's easier in Swift to
work with them as arrays. We'll turn the results back into strings
when we are done.
*/
    let x = [Character](X.characters)
    let y = [Character](Y.characters)
    
/*:
# Using the recursion formula from the above wiki page
    
(using python string slicing syntax for brevity)

    LCS(X,Y) = ""                                   if X == "" or Y == ""
    LCS(X,Y) = LCS(X[:-1],Y[:-1]) + X[-1]           if X[-1] == Y[-1]
    LCS(X,Y) = longest(LCS(X[:-1],Y),LCS(X,Y[:-1]))
    
The advantage here is mainly simplicity.
*/
    func LCS_recursive(a: Int, _ b: Int) -> [[Character]]
    {
//: Rule #1
        if a == 0 || b == 0 { return [[]] }

        let (i, j) = (a - 1, b - 1)
//: Rule #2
        if x[i] == y[j] { return LCS_recursive(i, j).map { $0 + [x[i]] } }

//: Rule #3
        let (u, l) = (LCS_recursive(i, b), LCS_recursive(a, j))
        var rslt = [[Character]]()
        if u[0].count >= l[0].count { rslt += u }
        if l[0].count >= u[0].count { rslt += l }
        return rslt
    }
    
/*:
# Using "dynamic programming" - it's just so dynamic!

This is the "full" version where the cells of the workspace array hold the
intermediate results. It has the advantage of having the answer in one go.
It has the disadvantage of using lots of memory. However, it can be reduced
dramatically, but I won't do so here for simplicity.
*/
    func LCS_dynamic() -> [[Character]]
    {
        var score = (0...y.count).map { _ in (0...x.count).map { _ in [[Character]]() } }
        for i in 1...y.count {
            for j in 1...x.count {
//: Rule #2
                if x[j-1] == y[i-1] {
                    score[i][j] = score[i-1][j-1].map { $0 + [x[j-1]] }
                }
                else {
                    let (u, l) = (score[i-1][j], score[i][j-1])
//: Rule #3
                    if u[0].count >= l[0].count { score[i][j] += u }
                    if l[0].count >= u[0].count { score[i][j] += l }
                }
            }
        }
        return score[y.count][x.count]
    }

/*:
This is the traceback version where the workspace array contains only the length.
In the full version, the cells of the  workspace array held the intermediate results
(a vector of subsequences), while in this version, the cells of the workspace array
only each hold a single integer. It's advantage is in using much less memory.
It's disadvantage is that it requires an addition step, the traceback, to compute
the final result.

However, it has an additional advantage that is not so readily apparent. The values
that are held in the workspace array, here the lengths of the subsequences, are
actually scores. This can be generalized to situations where the length is not the
measure of merit. In other words, with the appropriate scoring matrix, it can be
transformed into Smith-Waterman.
*/
    func LCS_traceback() -> [[Character]]
    {
        var score = (0...y.count).map { _ in (0...x.count).map { _ in 0 } }
        for i in 1...y.count {
            for j in 1...x.count {
                if x[j-1] == y[i-1] {
                    score[i][j] = score[i-1][j-1] + 1
                }
                else {
                    let u = score[i-1][j]
                    let l = score[i][j-1]
                    
                    if u > l {
                        score[i][j] = u
                    }
                    else {
                        score[i][j] = l
                    }
                }
            }
        }
        func traceback(a: Int, _ b: Int) -> [[Character]]
        {
            if a == 0 || b == 0 { return [[]] }
            let i = a - 1
            let j = b - 1
            
            if x[i] == y[j] { return traceback(i, j).map { $0 + [x[i]] } }

            var rslt = [[Character]]()
            if score[b][i] >= score[j][a] { rslt += traceback(i, b) }
            if score[j][a] >= score[b][i] { rslt += traceback(a, j) }
            return rslt
        }
        return traceback(x.count, y.count)
    }
    
    let lcs = LCS_traceback()
    //let lcs = LCS_dynamic()
    //let lcs = LCS_recursive(x.count, y.count)
    
//: Turn the arrays back into strings and unique them
    var rslt = [String]()
    for s in lcs.map({ String($0) }).sort() {
        if rslt.count == 0 || rslt.last != s {
            rslt.append(s)
        }
    }
    return rslt
}

//print(LCS("BANANA", "BATANA"))
print(LCS("AGCAT", "GAC"))
