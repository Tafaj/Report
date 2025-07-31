report 50101 "JOVI Packing Slip"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/JOVIPackingSlip.rdlc';
    Caption = 'Packing Slip';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = false;
    ProcessingOnly = false;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.";

            column(No_; "No.") { }
            column(Purchase_Order_No_; "Your Reference") { }
            column(Document_Date; Format("Document Date", 0, 4)) { }
            column(Shipment_Date; Format("Shipment Date", 0, '<Day,2> <Month Text,3> <Year4>')) { }
            column(Due_Date; Format("Due Date", 0, '<Day,2> <Month Text,3> <Year4>')) { }
            column(Currency_Code; "Currency Code") { }
            column(Shipment_Method_Code; "Shipment Method Code") { }
            column(Location_Code; "Location Code") { }
            column(Sell_to_Customer_No_; "Sell-to Customer No.") { }
            column(Sell_to_Name; "Sell-to Customer Name") { }
            column(Sell_to_Address; "Sell-to Address") { }
            column(Sell_to_City; "Sell-to City") { }
            column(Sell_to_Post_Code; "Sell-to Post Code") { }
            column(Sell_to_Country_Region_Code; "Sell-to Country/Region Code") { }
            column(Ship_to_Code; "Ship-to Code") { }
            column(Ship_to_Name; "Ship-to Name") { }
            column(Ship_to_Address; "Ship-to Address") { }
            column(Ship_to_City; "Ship-to City") { }
            column(Ship_to_Post_Code; "Ship-to Post Code") { }
            column(Ship_to_Country_Region_Code; "Ship-to Country/Region Code") { }
            column(JOVI_No_of_Pallets; "JOVI No. of Pallets") { }
            column(JOVI_No_of_Cartons; "JOVI No. of Cartons") { }
            column(Language_Code; "Language Code") { }
            column(Shipment_No; PackingSlipNo) { }
            column(JOVI_Packing_Slip_Notes; "JOVI Packing Slip Notes") { }
            column(TotalQtyShipped_Text; Format(TotalQtyShipped) + ' PCS') { }
            column(IsFrenchCustomer; IsFrenchCustomer) { }

            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                column(Line_Item_No_; "No.") { }
                column(Line_Description; Description) { }
                column(Line_Quantity; Quantity) { }
                column(Line_Quantity_Text; Format(Quantity) + ' ' + GetUOMText()) { }

                trigger OnAfterGetRecord()
                begin
                    TotalQtyShipped += Quantity;
                end;
            }

            dataitem(Terms; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TermsText; TermsText) { }
            }

            trigger OnAfterGetRecord()
            var
                InStream: InStream;
            begin
                TotalQtyShipped := 0;
                EnsurePackingSlipNo();

                // Determina se è un cliente francese
                IsFrenchCustomer := ("Language Code" = 'FRC') or ("Language Code" = 'fr-CA');

                SalesReceivablesSetup.Get();

                // Lettura termini EN
                SalesReceivablesSetup.CalcFields("JOVI ENUS Terms");
                Clear(TermsTextEN);
                if SalesReceivablesSetup."JOVI ENUS Terms".HasValue() then begin
                    SalesReceivablesSetup."JOVI ENUS Terms".CreateInStream(InStream, TextEncoding::UTF8);
                    InStream.ReadText(TermsTextEN);
                end;

                // Lettura termini FR
                SalesReceivablesSetup.CalcFields("JOVI fr-CA Terms");
                Clear(TermsTextFR);
                if SalesReceivablesSetup."JOVI fr-CA Terms".HasValue() then begin
                    SalesReceivablesSetup."JOVI fr-CA Terms".CreateInStream(InStream, TextEncoding::UTF8);
                    InStream.ReadText(TermsTextFR);
                end;

                // Imposta i termini in base alla lingua
                if IsFrenchCustomer then
                    TermsText := TermsTextFR
                else
                    TermsText := TermsTextEN;
            end;
        }
    }

    labels
    {
        PackingSlipLbl = 'BON DE LIVRAISON PACKING SLIP';
        OrderNoLbl = 'Nº DE COMMANDE ORDER No.';
        PONoLbl = 'PO No.';
        DueDateLbl = 'DATE D''ÉCHÉANCE DUE DATE';
        ShipDateLbl = 'DATE D''EXPÉDITION SHIP DATE';
        ViaLbl = 'PAR VIA VIA';
        CurrencyLbl = 'DEVISE CURRENCY';
        StoreNoLbl = 'Nº DE MAGASIN STORE No.';
        PalletsLbl = 'Nº DE PALETTES No. OF PALLETS';
        CartonsLbl = 'Nº DE CARTONS No. OF CARTONS';
        SoldToLbl = 'VENDU À: SOLD TO:';
        ShipToLbl = 'EXPÉDIÉ À: SHIP TO:';
        ItemLbl = 'ARTICLE ITEM';
        DescriptionLbl = 'DESCRIPTION DESCRIPTION';
        ShipQtyLbl = 'QTÉ EXPÉDIÉE SHIP QTY';
        NotesLbl = 'NOTES';
        TotalQtyShippedLbl = 'QTÉ TOTALE EXPÉDIÉE TOTAL QTY SHIPPED';
    }

    trigger OnInitReport()
    begin
        SalesReceivablesSetup.Get();
    end;

    local procedure EnsurePackingSlipNo()
    var
        PackingSlipManagement: Codeunit "JOVI Packing Slip Management";
    begin
        if "Sales Header"."JOVI Packing Slip No." = '' then
            "Sales Header"."JOVI Packing Slip No." := PackingSlipManagement.GetNewPackingSlipNo("Sales Header");

        PackingSlipNo := "Sales Header"."JOVI Packing Slip No.";
    end;

    local procedure GetUOMText(): Text
    begin
        if "Sales Line"."Unit of Measure" <> '' then
            exit("Sales Line"."Unit of Measure");
        exit('PCS');
    end;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        TotalQtyShipped: Decimal;
        TermsTextEN: Text;
        TermsTextFR: Text;
        TermsText: Text;
        PackingSlipNo: Code[20];
        IsFrenchCustomer: Boolean;
}