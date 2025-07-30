codeunit 50100 "JOVI Packing Slip Management"
{
    procedure GetNewPackingSlipNo(var SalesHeader: Record "Sales Header"): Code[20]
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."JOVI Packing Slip Nos." = '' then
            Error('JOVI Packing Slip Nos. not set in Sales & Receivables Setup');

        SalesHeader."JOVI Packing Slip No." :=
            NoSeriesMgt.GetNextNo(SalesReceivablesSetup."JOVI Packing Slip Nos.", Today, false);
        SalesHeader.Modify();

        exit(SalesHeader."JOVI Packing Slip No.");
    end;
}