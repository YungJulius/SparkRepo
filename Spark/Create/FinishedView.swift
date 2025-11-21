struct FinishedView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .foregroundColor(BrandStyle.primary)

            Text("Entry successfully locked and saved!")
                .font(BrandStyle.title)

            Button("Return to Home") {
                dismiss()
            }
            .font(BrandStyle.button)
            .padding()
            .background(BrandStyle.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}