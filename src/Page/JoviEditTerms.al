page 50101 "JOVI Edit Terms"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Edit Terms & Conditions';
    SourceTable = "Integer";
    SourceTableView = WHERE(Number = CONST(1));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(TermsText; TermsText)
                {
                    ApplicationArea = All;
                    Caption = 'Terms & Conditions';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                ApplicationArea = All;
                Caption = 'OK';
                Image = Approve;
                InFooterBar = true;
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                Image = Cancel;
                InFooterBar = true;
                trigger OnAction()
                begin
                    TermsText := '';
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        TermsText: Text;

    procedure SetTermsText(NewTermsText: Text)
    begin
        TermsText := NewTermsText;
    end;

    procedure GetTermsText(): Text
    begin
        exit(TermsText);
    end;
}