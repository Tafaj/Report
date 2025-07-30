tableextension 50101 "JOVI Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(50100; "JOVI No. of Pallets"; Integer)
        {
            Caption = 'No. of Pallets';
            DataClassification = CustomerContent;
        }
        field(50101; "JOVI No. of Cartons"; Integer)
        {
            Caption = 'No. of Cartons';
            DataClassification = CustomerContent;
        }
        field(50102; "JOVI Packing Slip No."; Code[20])
        {
            Caption = 'JOVI Packing Slip No.';
            DataClassification = CustomerContent;
        }
        field(50103; "JOVI Packing Slip Notes"; Text[250])
        {
            Caption = 'JOVI Packing Slip Notes';
            DataClassification = CustomerContent;
        }
    }
}