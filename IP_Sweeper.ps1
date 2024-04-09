Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "IP Sweeper"
$form.Size = New-Object System.Drawing.Size(400,250)
$form.StartPosition = "CenterScreen"

# Add labels
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,20)
$label1.Size = New-Object System.Drawing.Size(80,20)
$label1.Text = "First IP:"
$form.Controls.Add($label1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,50)
$label2.Size = New-Object System.Drawing.Size(80,20)
$label2.Text = "Last IP:"
$form.Controls.Add($label2)

# Add textboxes
$textbox1 = New-Object System.Windows.Forms.TextBox
$textbox1.Location = New-Object System.Drawing.Point(100,20)
$textbox1.Size = New-Object System.Drawing.Size(150,20)
$form.Controls.Add($textbox1)

$textbox2 = New-Object System.Windows.Forms.TextBox
$textbox2.Location = New-Object System.Drawing.Point(100,50)
$textbox2.Size = New-Object System.Drawing.Size(150,20)
$form.Controls.Add($textbox2)

# Add scan button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(150,80)
$button.Size = New-Object System.Drawing.Size(100,30)
$button.Text = "Scan"
$form.Controls.Add($button)

# Add progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,120)
$progressBar.Size = New-Object System.Drawing.Size(370,20)
$progressBar.Style = 'Continuous'
$form.Controls.Add($progressBar)

# Add progress label
$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Location = New-Object System.Drawing.Point(10,150)
$progressLabel.Size = New-Object System.Drawing.Size(200,20)
$form.Controls.Add($progressLabel)

# Add scan button click event
$button.Add_Click({
    $firstIP = $textbox1.Text
    $lastIP = $textbox2.Text

    # Ask for the file path to save the CSV
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "CSV files (*.csv)|*.csv"
    $saveFileDialog.Title = "Save CSV File"
    $saveFileDialog.ShowDialog() | Out-Null
    $filePath = $saveFileDialog.FileName

    # Create CSV header
    "IP Address,Status" | Out-File -FilePath $filePath -Encoding utf8

    # Ping each IP and write the result to the CSV
    $firstIPParts = $firstIP.Split('.')
    $lastIPParts = $lastIP.Split('.')
    $ipRange = $firstIPParts[3]..$lastIPParts[3]

    $progressBar.Maximum = $ipRange.Count
    $progressBar.Value = 0
    $progress = 0

    foreach ($ip in $ipRange) {
        $currentIP = "$($firstIPParts[0]).$($firstIPParts[1]).$($firstIPParts[2]).$ip"
        if (Test-Connection -ComputerName $currentIP -Count 1 -Quiet) {
            "$currentIP,UP" | Out-File -FilePath $filePath -Append -Encoding utf8
        } else {
            "$currentIP,DOWN" | Out-File -FilePath $filePath -Append -Encoding utf8
        }

        $progress++
        $progressBar.Value = $progress
        $progressLabel.Text = "Progress: $progress / $($progressBar.Maximum)"
    }

    [System.Windows.Forms.MessageBox]::Show("Scan completed. Results saved to $filePath", "Scan Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Display the form
$form.ShowDialog() | Out-Null
