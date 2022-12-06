//
//  MainView.swift
//  WeatherPacker
//
//  Created by 薛渤凡 on 11/6/22.
//

import SwiftUI

struct MainView: View {
    @State var signInSuccess = false
    @State var userId = UUID()
    var tripCollectionRepository = TripCollectionRepository()
    var userAuth = UserAuth()
    var listBg = ListBackground()
    
    var body: some View {
        return Group {
            if signInSuccess {
                TripView(signInSuccess: $signInSuccess)
            } else {
                LoginView(signInSuccess: $signInSuccess)
            }
        }
        .environmentObject(tripCollectionRepository)
        .environmentObject(userAuth)
        .environmentObject(listBg)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct TripView: View {
  @Binding var signInSuccess:Bool
  @EnvironmentObject var userAuth: UserAuth
  @EnvironmentObject var tripCollectionRepository:TripCollectionRepository
  
  var body: some View {
    NavigationStack {
      VStack {
        ScrollView {
            VStack {
                Text("Coming Trips").padding(12).font(Font.headline.weight(.bold))
                VStack {
                  ForEach(tripCollectionRepository.tripsNotExpired) { trip in
                    TripRowView(trip: trip)
                  }
                }
                Text("Past Trips").padding(12).font(Font.headline.weight(.bold))
                VStack {
                  ForEach(tripCollectionRepository.tripsExpired) { trip in
                    TripRowView(trip: trip)
                  }
                }
                
            }
        }
      
        NavigationLink(destination:CreationView()) {
          Text("Create New Trip")
            .frame(maxWidth: .infinity, maxHeight: 40)
            .font(.title3.bold())
            .foregroundColor(.white)
            .background(Color("PrimaryOrange"))
            .cornerRadius(20)
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
      }
      .background(Color.white)
      .navigationBarTitle("Trips", displayMode: .inline)
      .toolbarBackground(Color("PrimaryOrange"),
                         for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            Image("Logout")
              .resizable()
              .frame(width: 24, height: 24)
              .onTapGesture {
                self.signInSuccess = false
              }
          }
        }
      }
    }
  }
}




struct LoginView: View {
    
    @Binding var signInSuccess:Bool
    
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var tripCollectionRepository:TripCollectionRepository
    
    @State var userName = ""
    @State var pwd = ""
    
    @ObservedObject var userRepository = UserRepository()
    
    var body: some View {
      NavigationView {
            ZStack {
                VStack {
                 Image("Login").resizable().frame(width:360 ,height:300)
                    Form{
                        TextField("User Name", text: $userName)
                        SecureField("Password", text: $pwd)
                    }.scrollContentBackground(.hidden)
                    Button(action: {
                        if userRepository.verify(userName: userName, pwd: pwd) {
                            self.userAuth.userId = userRepository.getUserId(userName: userName)
                            print("Tag - LoginView getById NEXT")
                            self.tripCollectionRepository.getById(userId:userAuth.userId)
                            print("Tag - LoginView getById FINISHED")
                            self.signInSuccess = true
                        }
                    }) {
                        Text("Login")
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .background(Color("PrimaryOrange"))
                    .cornerRadius(20)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }.background(Color.white)
         
            }
      
        }
  
    }
}

struct CreationView: View {
    @State var isActive = false
    @State private var location = ""
    @State private var goToStartDate = false
    
    @ObservedObject var clothesController = ClothesController()
    
    @EnvironmentObject var userAuth:UserAuth
    //@EnvironmentObject var tripRepository:TripCollectionRepository
    
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Create Your Trip")
                    .font(.title)
                    .fontWeight(.bold)
                Form {
                    TextField("Location", text: $location)
                }.scrollContentBackground(.hidden)
              
              Image("Creation").resizable().frame(width:350 ,height:210)
              NavigationLink(
                    destination:TripStartView(
                        rootIsActive: self.$isActive,
                        location: location,
                        clothesController: clothesController),
                    isActive: self.$isActive)
                {
                    Text("Next Step")
                        .onTapGesture {
                            clothesController.getWeatherInfo(city: location)
                            self.isActive = true
                        }
//                        .alert(isPresented: $isValid) {
//                            Alert(
//                                title: Text("Destination Not Available"),
//                                message: Text("Cannot find the destination typed in, please check spelling")
//                            )
//                        }
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .background(Color("PrimaryOrange"))
                        .cornerRadius(20)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
        }//.navigationBarHidden(true)
    }
}

struct TripStartView: View {
    
    @Binding var rootIsActive : Bool
    @State private var startDate = Date()
    @EnvironmentObject var userAuth:UserAuth
    
    var location = String()
    var clothesController = ClothesController()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When does your trip start?")
                    .font(.title)
                    .fontWeight(.bold)
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    in:Date()...Date().addingTimeInterval(529200),
                    displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .accentColor(Color("PrimaryOrange"))
                Spacer()
              Image("Creation").resizable().frame(width:350 ,height:210)
                NavigationLink(
                    destination:TripEndView(
                        shouldPopToRootView: self.$rootIsActive,
                        location: location,
                        startDate: startDate,
                        clothesController: clothesController)){
                            Text("Next Step")
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .background(Color("PrimaryOrange"))
                                .cornerRadius(20)
                                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
        }.navigationBarHidden(true)
    }
}

struct TripEndView: View {
    
    @Binding var shouldPopToRootView:Bool
    
    @State private var endDate = Date()
    @State private var goToTripView = false
    @ObservedObject var tripController = TripController()
    @EnvironmentObject var userAuth:UserAuth
    @EnvironmentObject var tripCollectionReposiroty:TripCollectionRepository
    @EnvironmentObject var listBG: ListBackground
    
    var location = String()
    var startDate = Date()
    var clothesController = ClothesController()
    
    var body: some View {
        VStack {
            Text("When does your trip end?")
                .font(.title)
                .fontWeight(.bold)
            DatePicker(
                "Start Date",
                selection: $endDate,
                in:Date()...Date().addingTimeInterval(529200),
                displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .accentColor(Color("PrimaryOrange"))
            Spacer()
          Image("Creation").resizable().frame(width:350 ,height:210)
            Button(action:{
                var tripId = tripController.update(userId: userAuth.userId, location: location, startDate: startDate, endDate: endDate, tripRepo: tripCollectionReposiroty)
                clothesController.calculate_date(startDate: startDate, endDate: endDate)
                clothesController.generatePacker()
                clothesController.createPacker(tripId: tripId, location: location)
                listBG.bgIndex = 0
                self.shouldPopToRootView = false
            }){
                Text("Create Trip")
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .background(Color("PrimaryOrange"))
                    .cornerRadius(20)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }.navigationBarHidden(true)
    }
}

