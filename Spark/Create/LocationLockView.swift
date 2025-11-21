import SwiftUI
import MapKit

struct LocationLockView: View {
    @EnvironmentObject var location: LocationService

    @State private var region = MKCoordinateRegion()
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showFullScreenMap = false

    var body: some View {
        VStack(spacing: 24) {

            Text("Location Lock")
                .font(BrandStyle.title)

            Text("Choose a location, which needs to be visited, to unlock your note")
                .font(BrandStyle.body)
                .foregroundColor(BrandStyle.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                Map(coordinateRegion: $region, annotationItems: mapPins) { pin in
                    MapMarker(coordinate: pin)
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showFullScreenMap = true
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(12)
                    }
                }
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    goNext(skip: true)
                } label: {
                    Text("Skip Location")
                        .font(BrandStyle.button)
                        .foregroundColor(BrandStyle.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandStyle.card)
                        .cornerRadius(12)
                }

                Button {
                    goNext(skip: false)
                } label: {
                    Text("Use Location")
                        .font(BrandStyle.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandStyle.primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .onAppear { updateRegion() }
        .fullScreenCover(isPresented: $showFullScreenMap) {
            FullScreenLocationPicker(selectedCoordinate: $selectedCoordinate)
        }
    }

    private var mapPins: [CLLocationCoordinate2D] {
        if let selected = selectedCoordinate {
            return [selected]
        } else if let current = location.currentLocation {
            return [current.coordinate]
        }
        return []
    }

    private func updateRegion() {
        if let current = location.currentLocation {
            region = MKCoordinateRegion(
                center: current.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    private func goNext(skip: Bool) {
        // Navigation handled in parent LockConfig flow
    }
}

struct FullScreenLocationPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCoordinate: CLLocationCoordinate2D?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: .init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                .ignoresSafeArea()

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .offset(y: -20)

            VStack {
                Spacer()
                Button("Set Location") {
                    selectedCoordinate = region.center
                    dismiss()
                }
                .font(BrandStyle.button)
                .padding()
                .frame(maxWidth: .infinity)
                .background(BrandStyle.primary)
                .foregroundColor(.white)
                .cornerRadius(14)
                .padding()
            }
        }
    }
}
