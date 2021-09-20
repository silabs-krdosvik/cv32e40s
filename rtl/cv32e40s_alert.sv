// Copyright 2021 Silicon Labs, Inc.
//
// This file, and derivatives thereof are licensed under the
// Solderpad License, Version 2.0 (the "License").
//
// Use of this file means you agree to the terms and conditions
// of the license and are in full compliance with the License.
//
// You may obtain a copy of the License at:
//
//     https://solderpad.org/licenses/SHL-2.0/
//
// Unless required by applicable law or agreed to in writing, software
// and hardware implementations thereof distributed under the License
// is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, EITHER EXPRESSED OR IMPLIED.
//
// See the License for the specific language governing permissions and
// limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Halfdan Bechmann  -  halfdan.bechmann@silabs.com           //
//                                                                            //
// Design Name:    Alert                                                      //
// Project Name:   CV32E40S                                                   //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    This module combines and flops the core alert outputs.     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module cv32e40s_alert
  import cv32e40s_pkg::*;
  (input logic               clk,
   input logic               rst_n,

   // Alert Trigger inputs
   input  alert_trigger_t    alert_triggers_i,

   // Alert outputs
   output logic              alert_minor_o,
   output logic              alert_major_o
   );

  logic         rf_ecc_err_q;

  // Store alert input for signals that are not guaranteed to be single cycle
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      rf_ecc_err_q <= 1'b0;
    end else begin
      rf_ecc_err_q <= alert_triggers_i.rf_ecc_err;
    end
  end

    // Alert Outputs
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      alert_minor_o <= 1'b0;
    end else begin
      // Minor Alert
      alert_minor_o <= 1'b0; // todo: add minor alert inputs

      // Major Alert
      alert_major_o <= alert_triggers_i.rf_ecc_err && !rf_ecc_err_q ||
                       1'b0; // todo: add major alert inputs
    end
  end

endmodule // cv32e40s_alert
