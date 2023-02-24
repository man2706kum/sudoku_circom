pragma circom 2.0.0;

//check that in0 != in1
template NonEqual() {
    signal input in0;
    signal input in1;

    signal inverse;
    inverse <-- 1/(in0 - in1);
    inverse * (in0 - in1) === 1;
}

template Distinct(n) {

    signal input in[n];
    component nonEqual[n][n];

    for(var i = 0; i < n; i++) {
        for( var j = 0 ; j< i; j++){
            nonEqual[i][j] = NonEqual();
            nonEqual[i][j].in0 <== in[i];
            nonEqual[i][j].in1 <== in[j];
        }
    }
}

//checking 0 <= in < 16
template Bits4() {
    signal input in;
    signal bits[4];

    var bitsum = 0;

    for(var i = 0; i < 4; i++){
        bits[i] <-- (in >> 1) & 1;
        bits[i] * (bits[i] - 1) === 0;
        bitsum = bitsum + 2 ** i * bits[i]; 
    }

    bitsum === in;
}

// Enforcing that 1 <= in <= 9
template OneToNine() {
    signal input in;
    component lowerBound = Bits4();
    component upperBound = Bits4();

    lowerBound.in <== in - 1;
    upperBound.in <== in + 6;
}

template Sudoku(n) {
    // solution is a 2D array: indices are (row_i, col_i)
    signal input solution[n][n];
    //puzzle is also same, but a zero indicate a blank
    signal input puzzle[n][n];

    component inRange[n][n];
    for(var i = 0; i < n; i++) {
        for( var j = 0; j < n; j++) {
            inRange[i][j] = OneToNine();
            inRange[i][j].in <== solution[i][j];
        }
    }

    // ensure that puzzle and solution agrees
    for(var i = 0; i < n; i++) {
        for( var j = 0; j < n; j++) {
            
            // puzzle_cell * (puzzle_cell - solution_cell) === 0
            puzzle[i][j] * (puzzle[i][j] - solution[i][j]) === 0;

        }
    }

    // ensure uniqueness in rows

    component distinct_row[n];
    for(var i = 0; i < n; i++) {
        distinct_row[i] = Distinct(n);
        for(var j = 0;  j < n; j++) {
            distinct_row[i].in[j] <== solution[i][j];
        }
    }

    // ensure uniqueness in columns

    component distinct_col[n];
    for(var i = 0; i < n; i++) {
        distinct_col[i] = Distinct(n);
        for(var j = 0;  j < n; j++) {
            distinct_col[i].in[j] <== solution[j][i];
        }
    }

    // // ensure uniqueness in 3 x 3 grid
    // component distinct_grid[n];
    // var k = 0;
    // var m = 0;
    // for(var m = 0; m < 3; m++) {
    //     distinct_grid[m] = Distinct(n);
    //     for(var i = 0; i < 3; i++) {
    //         for(var j = 0; j < 3; j++) {
    //             var l = 3*m + i;
    //             distinct_grid[m].in[k] <== solution[l][j];
    //             k += 1;
    //         }
    //     }
    //     k = 0;
    // }
    // k = 0;
    // for(var m = 0; m < 3; m++) {
    //     for(var i = 0; i < 3; i++) {
    //         for(var j = 0; j < 3; j++) {
    //             var a = m+3;
    //             var b = 3*m + i;
    //             var c = j+3;
    //             distinct_grid[a] = Distinct(n);
    //             distinct_grid[a].in[k] <== solution[b][c];                
    //             k += 1;
    //         }
    //     }
    //     k = 0;
    // }
    // for(var m = 0; m < 3; m++) {
    //     for(var i = 0; i < 3; i++) {
    //         for(var j = 0; j < 3; j++) {
    //             distinct_grid[m+6] = Distinct(n);
    //             distinct_grid[m+6].in[k] <== solution[3*m +i][j+6];
    //             k += 1;
    //         }
    //     }
    //     k = 0;
    // }
    
}

component main {public[puzzle]} = Sudoku(9);