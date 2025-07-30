pageextension 50102 "JOVI Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("JOVI No. of Pallets"; Rec."JOVI No. of Pallets")
            {
                ApplicationArea = All;
                Caption = 'JOVI No. of Pallets';
                ToolTip = 'Specify the number of pallets for the JOVI Packing Slip.';
            }
            field("JOVI No. of Cartons"; Rec."JOVI No. of Cartons")
            {
                ApplicationArea = All;
                Caption = 'JOVI No. of Cartons';
                ToolTip = 'Specify the number of cartons for the JOVI Packing Slip.';
            }
            field("JOVI Packing Slip Notes"; Rec."JOVI Packing Slip Notes")
            {
                ApplicationArea = All;
                Caption = 'Packing Slip Notes';
                MultiLine = true;
            }
        }
    }
    actions
    {
        addlast("&Print")
        {
            action("JOVI Packing Slip")
            {
                ApplicationArea = All;
                Caption = 'Print Packing Slip';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //PromotedOnly = true;
                ToolTip = 'Print the JOVI Packing Slip for the Sales Order.';

                trigger OnAction()
                var
                    JOVIPackingSlip: Report "JOVI Packing Slip";
                begin
                    Report.Run(Report::"JOVI Packing Slip", true, false, Rec);
                end;
            }
        }
    }
}