table 50100 "JOVI Blob Reader"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; Content; Blob)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}