tableextension 50100 "JOVI Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "JOVI ENUS Terms"; Blob)
        {
            Caption = 'JOVI ENUS Terms and Conditions';
            DataClassification = CustomerContent;
        }
        field(50101; "JOVI fr-CA Terms"; Blob)
        {
            Caption = 'JOVI fr-CA Terms and Conditions';
            DataClassification = CustomerContent;
        }
        field(50102; "JOVI Packing Slip Nos."; Code[20])
        {
            Caption = 'JOVI Packing Slip Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
    }
}