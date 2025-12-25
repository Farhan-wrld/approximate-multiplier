`timescale 1ns / 1ps

module tb_approx_mult_with_error;
    reg  [7:0]  a;
    reg  [7:0]  b;
    wire [15:0] product_approx;
    integer     exact_product;
    integer     abs_error;
    real        error_percent;
    integer i, j;
    
    // ----- Error accumulation variables -----
    integer total_tests;
    integer total_abs_error;
    real    total_relative_error;
    real    total_error_percent;
    real    MAE;    // Mean Absolute Error
    real    MRE;    // Mean Relative Error
    real    MRED;   // Mean Relative Error Distance
    real    avg_percent_error;
    
    // ----- File handle for MATLAB export -----
    integer file;
    
    // DUT
    approx_mult_8bit dut (
        .a(a),
        .b(b),
        .product(product_approx)
    );
    
    initial begin
        a = 0;
        b = 0;
        total_tests = 0;
        total_abs_error = 0;
        total_relative_error = 0.0;
        total_error_percent = 0.0;
        
        // Open file for writing
        file = $fopen("multiplier_results.txt", "w");
        if (file == 0) begin
            $display("ERROR: Could not open file for writing!");
            $stop;
        end
        
        // Write header to file (optional, commented out for cleaner MATLAB import)
        // $fwrite(file, "A B Exact Approx AbsError ErrorPercent\n");
        
        $display("-------------------------------------------------------------");
        $display("  A    B   |   Exact    Approx   AbsError   Error(%%)       ");
        $display("-------------------------------------------------------------");
        
        // Test all combinations (you can change range for exhaustive testing)
        // For 8-bit: use i < 256 and j < 256 for complete coverage
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                a = i;
                b = j;
                #1;
                
                exact_product = a * b;
                
                // absolute error
                if (exact_product >= product_approx)
                    abs_error = exact_product - product_approx;
                else
                    abs_error = product_approx - exact_product;
                
                // error percentage
                if (exact_product != 0)
                    error_percent = (abs_error * 100.0) / exact_product;
                else
                    error_percent = 0.0;
                
                // ----- Write to file for MATLAB -----
                $fwrite(file, "%d %d %d %d %d %f\n", 
                        a, b, exact_product, product_approx, 
                        abs_error, error_percent);
                
                // ----- accumulate stats -----
                total_tests = total_tests + 1;
                total_abs_error = total_abs_error + abs_error;
                total_error_percent = total_error_percent + error_percent;
                
                if (exact_product != 0)
                    total_relative_error = total_relative_error + (abs_error * 1.0 / exact_product);
                else
                    total_relative_error = total_relative_error + 0.0;
                
                // Display only first few and some samples (to avoid console overflow)
                if ((i < 16 && j < 16) || (i % 32 == 0 && j % 32 == 0)) begin
                    $display(" %3d  %3d | %7d  %7d  %8d   %6.2f",
                             a, b, exact_product, product_approx,
                             abs_error, error_percent);
                end
            end
        end
        
        // Close the file
        $fclose(file);
        
        // ----- final metrics -----
        MAE  = total_abs_error * 1.0 / total_tests;
        MRE  = total_relative_error / total_tests;
        MRED = MRE;
        avg_percent_error = total_error_percent / total_tests;
        
        $display("-------------------------------------------------------------");
        $display(" Total test cases        = %0d", total_tests);
        $display(" Total Absolute Error    = %0d", total_abs_error);
        $display(" Mean Absolute Error     = %.4f", MAE);
        $display(" Mean Relative Error     = %.6f", MRE);
        $display(" Mean Relative Error Dist= %.6f", MRED);
        $display(" Avg Error Percentage    = %.4f%%", avg_percent_error);
        $display("-------------------------------------------------------------");
        $display(" Data saved to: multiplier_results.txt");
        $display("-------------------------------------------------------------");
        
        $stop;
    end
endmodule