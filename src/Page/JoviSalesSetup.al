page 50100 "JOVI Sales & Receivables Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'JOVI Sales & Receivables Setup';
    SourceTable = "Sales & Receivables Setup";
    UsageCategory = Documents;
    Editable = true;

    layout
    {
        area(content)
        {
            group("JOVI Packing Slip")
            {
                Caption = 'JOVI Packing Slip Configuration';

                group("Terms & Conditions")
                {
                    Caption = 'Terms & Conditions';

                    field("JOVI ENUS Terms"; Rec."JOVI ENUS Terms")
                    {
                        ApplicationArea = All;
                        Caption = 'JOVI English (ENUS) Terms';
                        ToolTip = 'Specify the Terms and Conditions in English for the Packing Slip.';
                        Visible = false;
                    }
                    field("JOVI fr-CA Terms"; Rec."JOVI fr-CA Terms")
                    {
                        ApplicationArea = All;
                        Caption = 'JOVI French (fr-CA) Terms';
                        ToolTip = 'Specify the Terms and Conditions in French for the Packing Slip.';
                        Visible = false;
                    }

                    field("TermsTextENPlaceholder"; TermsTextENPlaceholder)
                    {
                        ApplicationArea = All;
                        Caption = 'JOVI English (ENUS) Terms';
                        MultiLine = true;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            EditTerms(true);
                        end;
                    }
                    field("TermsTextFRPlaceholder"; TermsTextFRPlaceholder)
                    {
                        ApplicationArea = All;
                        Caption = 'JOVI French (fr-CA) Terms';
                        MultiLine = true;

                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            EditTerms(false);
                        end;
                    }
                }
                group("Additional Settings")
                {
                    Caption = 'Additional Settings';

                    field("JOVI Packing Slip Nos."; Rec."JOVI Packing Slip Nos.")
                    {
                        ApplicationArea = All;
                        Caption = 'Packing Slip No. Series';
                        TableRelation = "No. Series";
                        ToolTip = 'Specify the No. Series to use for generating Packing Slip numbers.';
                        Editable = true;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LoadTerms();
    end;

    var
        TermsTextENPlaceholder: Text;
        TermsTextFRPlaceholder: Text;

    procedure LoadTerms()
    var
        InStreamEN: InStream;
        InStreamFR: InStream;
    begin
        Clear(TermsTextENPlaceholder);
        Clear(TermsTextFRPlaceholder);

        Rec.CalcFields("JOVI ENUS Terms", "JOVI fr-CA Terms");

        if Rec."JOVI ENUS Terms".HasValue then begin
            Rec."JOVI ENUS Terms".CreateInStream(InStreamEN, TextEncoding::UTF8);
            InStreamEN.Read(TermsTextENPlaceholder);
        end;

        if Rec."JOVI fr-CA Terms".HasValue then begin
            Rec."JOVI fr-CA Terms".CreateInStream(InStreamFR, TextEncoding::UTF8);
            InStreamFR.Read(TermsTextFRPlaceholder);
        end;
    end;

    local procedure EditTerms(IsEnglish: Boolean)
    var
        EditTermsPage: Page "JOVI Edit Terms";
        TermsText: Text;
        InStream: InStream;
        OutStream: OutStream;
    begin
        if (IsEnglish and Rec."JOVI ENUS Terms".HasValue) or
           (not IsEnglish and Rec."JOVI fr-CA Terms".HasValue) then begin
            if IsEnglish then
                Rec."JOVI ENUS Terms".CreateInStream(InStream, TextEncoding::UTF8)
            else
                Rec."JOVI fr-CA Terms".CreateInStream(InStream, TextEncoding::UTF8);

            InStream.Read(TermsText);
        end;

        EditTermsPage.SetTermsText(TermsText);

        if EditTermsPage.RunModal() = Action::OK then begin
            TermsText := EditTermsPage.GetTermsText();

            if IsEnglish then
                Clear(Rec."JOVI ENUS Terms")
            else
                Clear(Rec."JOVI fr-CA Terms");

            if IsEnglish then
                Rec."JOVI ENUS Terms".CreateOutStream(OutStream, TextEncoding::UTF8)
            else
                Rec."JOVI fr-CA Terms".CreateOutStream(OutStream, TextEncoding::UTF8);

            OutStream.WriteText(TermsText);

            if Rec.Modify(true) then
                Commit();
            LoadTerms();
            CurrPage.Update(false);

            Message('Terms saved successfully.');
        end;
    end;
}
