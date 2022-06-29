namespace AmbermoonMapCharEditor
{
    public class NumericUpDownColumn : DataGridViewColumn
    {
        public NumericUpDownColumn()
            : base(new NumericUpDownCell())
        {

        }

        public override DataGridViewCell CellTemplate
        {
            get { return base.CellTemplate; }
            set
            {
                if (value != null && !value.GetType().IsAssignableFrom(typeof(NumericUpDownCell)))
                {
                    throw new InvalidCastException("Must be a NumericUpDownCell");
                }
                base.CellTemplate = value;
                (base.CellTemplate as NumericUpDownCell)!.Column = this;
            }
        }

        public override object Clone()
        {
            var clone = (base.Clone() as NumericUpDownColumn)!;

            clone.MinValue = MinValue;
            clone.MaxValue = MaxValue;

            return clone;
        }

        public uint MinValue
        {
            get;
            set;
        }

        public uint MaxValue
        {
            get;
            set;
        }
    }

    internal class NumericUpDownCell : DataGridViewTextBoxCell
    {
        internal NumericUpDownColumn Column { get; set; }

#pragma warning disable CS8618
        public NumericUpDownCell()
#pragma warning restore CS8618
            : base()
        {
            Style.Format = "0";
        }

        public override object Clone()
        {
            var clone = (base.Clone() as NumericUpDownCell)!;

            clone.Column = Column;

            return clone;
        }

        public override void InitializeEditingControl(int rowIndex, object initialFormattedValue, DataGridViewCellStyle dataGridViewCellStyle)
        {
            base.InitializeEditingControl(rowIndex, initialFormattedValue, dataGridViewCellStyle);
            var ctrl = (DataGridView!.EditingControl as NumericUpDownEditingControl)!;
            ctrl.Minimum = Column.MinValue;
            ctrl.Maximum = Column.MaxValue;
            ctrl.Value = Math.Max(ctrl.Minimum, Math.Min(Convert.ToUInt32(this.Value), ctrl.Maximum));
        }

        public override Type EditType
        {
            get { return typeof(NumericUpDownEditingControl); }
        }

        public override Type ValueType
        {
            get { return typeof(UInt32); }
        }

        public override object DefaultNewRowValue
        {
            get { return Column?.MinValue ?? 0u; }
        }

    }

    internal class NumericUpDownEditingControl : NumericUpDown, IDataGridViewEditingControl
    {
        private DataGridView? dataGridViewControl;
        private bool valueHasChanged = false;
        private int rowIndexNum;

        public NumericUpDownEditingControl()
            : base()
        {
            this.DecimalPlaces = 0;
        }

        public DataGridView EditingControlDataGridView
        {
            get { return dataGridViewControl!; }
            set { dataGridViewControl = value; }
        }

        public object EditingControlFormattedValue
        {
            get { return this.Value.ToString("0"); }
            set { this.Value = UInt32.Parse(value.ToString()!); }
        }
        public int EditingControlRowIndex
        {
            get { return rowIndexNum; }
            set { rowIndexNum = value; }
        }
        public bool EditingControlValueChanged
        {
            get { return valueHasChanged; }
            set { valueHasChanged = value; }
        }

        public Cursor EditingPanelCursor
        {
            get { return base.Cursor; }
        }

        public bool RepositionEditingControlOnValueChange
        {
            get { return false; }
        }

        public void ApplyCellStyleToEditingControl(DataGridViewCellStyle dataGridViewCellStyle)
        {
            this.Font = dataGridViewCellStyle.Font;
            this.ForeColor = dataGridViewCellStyle.ForeColor;
            this.BackColor = dataGridViewCellStyle.BackColor;
        }

        public bool EditingControlWantsInputKey(Keys keyData, bool dataGridViewWantsInputKey)
        {
            return (keyData == Keys.Left || keyData == Keys.Right ||
                keyData == Keys.Up || keyData == Keys.Down ||
                keyData == Keys.Home || keyData == Keys.End ||
                keyData == Keys.PageDown || keyData == Keys.PageUp);
        }

        public object GetEditingControlFormattedValue(DataGridViewDataErrorContexts context)
        {
            return this.Value.ToString();
        }

        public void PrepareEditingControlForEdit(bool selectAll)
        {
        }

        protected override void OnValueChanged(EventArgs e)
        {
            valueHasChanged = true;
            this.EditingControlDataGridView.NotifyCurrentCellDirty(true);
            base.OnValueChanged(e);
        }
    }
}
