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

            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                column(Line_Item_No_; "No.") { }
                column(Line_Description; Description) { }
                column(Line_Quantity; Quantity) { }
                column(Line_Quantity_Text; Format(Quantity) + ' ' + "Sales Line"."Unit of Measure") { }
                //column(Line_Quantity_Text; Format(Quantity) + ' PCS') { }
                trigger OnAfterGetRecord()
                begin
                    TotalQtyShipped += Quantity;
                end;
            }

            dataitem(Notes; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(NoteLine1; GetNoteLine(1)) { }
                column(NoteLine2; GetNoteLine(2)) { }
                column(NoteLine3; GetNoteLine(3)) { }
                column(NoteLine4; GetNoteLine(4)) { }
            }

            dataitem(Terms; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TermsText_EN; TermsTextEN) { }
                column(TermsText_FR; TermsTextFR) { }
            }

            dataitem(TotalQty; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TotalQtyShipped_Value; TotalQtyShipped) { }
                column(TotalQtyShipped_Text; Format(TotalQtyShipped)) { }
            }
            trigger OnAfterGetRecord()
            begin
                EnsurePackingSlipNo();

                SalesReceivablesSetup.Get();
                SalesReceivablesSetup.CalcFields("JOVI ENUS Terms", "JOVI fr-CA Terms");

                TempBlobReader.Content := SalesReceivablesSetup."JOVI ENUS Terms";
                ReadBlobAsText(TempBlobReader, TermsTextEN);
                TempBlobReader.Content := SalesReceivablesSetup."JOVI fr-CA Terms";
                ReadBlobAsText(TempBlobReader, TermsTextFR);
            end;

            trigger OnPreDataItem()
            begin
                TotalQtyShipped := 0;
            end;
        }
    }
    labels
    {
        PackingSlipLbl = 'PACKING SLIP';
        PackingSlipFrenchLbl = 'BON DE LIVRAISON';

        OrderNoLbl = 'ORDER No.';
        PONoLbl = 'PO No.';
        DueDateLbl = 'DUE DATE';
        ShipDateLbl = 'SHIP DATE';
        ViaLbl = 'VIA';
        CurrencyLbl = 'CURRENCY';
        StoreNoLbl = 'STORE No.';
        PalletsLbl = 'No. OF PALLETS';
        CartonsLbl = 'No. OF CARTONS';
        SoldToLbl = 'SOLD TO:';
        ShipToLbl = 'SHIP TO:';


        ItemLbl = 'ITEM';
        DescriptionLbl = 'DESCRIPTION';
        ShipQtyLbl = 'SHIP QTY';
        NotesLbl = 'NOTES';
        TotalQtyShippedLbl = 'TOTAL QTY SHIPPED';


        TotalQtyShippedFrenchLbl = 'QTÉ TOTALE EXPÉDIÉE';
        ItemFrenchLbl = 'ARTICLE';
        DescriptionFrenchLbl = 'DESCRIPTION';
        ShipQtyFrenchLbl = 'QTÉ EXPÉDIÉE';
        OrderFrenchLbl = 'Nº DE COMMANDE';
        DueDateFrenchLbl = 'DATE D''ÉCHÉANCE';
        ViaFrenchLbl = 'PAR VIA';
        ShipDateFrenchLbl = 'DATE D''EXPÉDITION';
        CurrencyFrenchLbl = 'DEVISE';
        StoreFrenchLbl = 'Nº DE MAGASIN';
        PalletsFrenchLbl = 'Nº DE PALETTES';
        CartonsFrenchLbl = 'Nº DE CARTONS';
        SoldToFrenchLbl = 'VENDU À:';
        ShipToFrenchLbl = 'EXPÉDIÉ À:';
    }
    local procedure ReadBlobAsText(var BlobReader: Record "JOVI Blob Reader" temporary; var ResultText: Text)
    var
        InStream: InStream;
    begin
        Clear(ResultText);
        if not BlobReader.Content.HasValue then
            exit;

        BlobReader.Content.CreateInStream(InStream, TextEncoding::UTF8);
        if not InStream.EOS then
            InStream.Read(ResultText);
    end;

    local procedure EnsurePackingSlipNo()
    var
        PackingSlipManagement: Codeunit "JOVI Packing Slip Management";
    begin
        if "Sales Header"."JOVI Packing Slip No." = '' then
            "Sales Header"."JOVI Packing Slip No." := PackingSlipManagement.GetNewPackingSlipNo("Sales Header");

        PackingSlipNo := "Sales Header"."JOVI Packing Slip No.";
    end;

    local procedure GetNoteLine(LineNo: Integer): Text
    var
        Notes: Text;
        NoteLines: List of [Text];
        i: Integer;
    begin
        Notes := "Sales Header"."JOVI Packing Slip Notes";
        NoteLines := Notes.Split('\');

        if LineNo <= NoteLines.Count() then
            exit(NoteLines.Get(LineNo));

        exit('');
    end;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        TempBlobReader: Record "JOVI Blob Reader" temporary;
        TotalQtyShipped: Decimal;
        TermsTextEN: Text;
        TermsTextFR: Text;
        PackingSlipNo: Code[20];
}