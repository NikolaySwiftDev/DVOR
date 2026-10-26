import Foundation

protocol DetailProtocol: AnyObject {
    func success(users: [UserModel], org: OrganizatorModel)
    func load()
    func updateUsers(model: [String])
    func error(error: String)
    func hideLoading()
    
    func successComments(comments: [CommentModel])
    func updateComments(comments: [CommentModel])
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         notification: NotificationManagerProtocol,
         comments: FirebaseCommentsManagerProtocol,
         storage: CityStorageProtocol?,
         moderation: ModerationManagerProtocol?
    )
    
    var users: [UserModel]? { get set }
    var org: OrganizatorModel? { get set }
    var comments: [CommentModel]? { get set }
    
    func fetchAllUsers(usersID: [String], orgID: String)
    func addUserToEvent(idEvent: String, date: Date, time: String, isComplete: Bool, city: CityModel)
    func removeUserFromEvent(idEvent: String)
    
    func fetchComments(idEvent: String)
    func updateComments(idEvent: String)
    func addComment(idEvent: String, text: String)
    func removeComment(idEvent: String, comment: CommentModel)
    func canDeleteComment(_ comment: CommentModel) -> Bool
    
    func canReportComment(_ comment: CommentModel) -> Bool
    func reportComment(idEvent: String, comment: CommentModel)
    func blockCommentAuthor(_ comment: CommentModel)
    
    func canReportEvent(orgId: String) -> Bool
    func reportEvent(eventId: String, eventName: String, orgId: String)
    
    func popVC()
    func shareEvent(eventID: String)
    func showDetailOrgInfo(model: OrganizatorModel)
    func showBottomAlertForUser(model: UserModel)
    func showLocationOnMap(location: String)
}

final class DetailPresenter: DetailPresenterProtocol {

    private weak var view: DetailProtocol?
    var users: [UserModel]?
    var org: OrganizatorModel?
    var comments: [CommentModel]?
    private var blockedIDs: Set<String> = []
    private let router: RouterMainProtocol
    private let network: FirebaseDataManagerProtocol
    private let firebase: FirebaseAuthManagerProtocol
    private let notification: NotificationManagerProtocol
    private let commentsManager: FirebaseCommentsManagerProtocol
    private let storage: CityStorageProtocol?
    private let moderation: ModerationManagerProtocol?
    
    required init(view: DetailProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  notification: NotificationManagerProtocol,
                  comments: FirebaseCommentsManagerProtocol,
                  storage: CityStorageProtocol?,
                  moderation: ModerationManagerProtocol?
    ) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.notification = notification
        self.commentsManager = comments
        self.storage = storage
        self.moderation = moderation
    }
    
    //MARK: - Fetch all users
    func fetchAllUsers(usersID: [String], orgID: String) {
        view?.load()
        loadBlockedUserIDs { [weak self] in
            guard let self = self else { return }

            self.network.fetchAllUsersFromEvent(usersID: usersID, orgId: orgID, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success((let users, let org)):
                    let visibleUsers = users.filter { !self.blockedIDs.contains($0.id) }
                    self.users = visibleUsers
                    self.org = org
                    self.view?.success(users: visibleUsers, org: org ?? OrganizatorModel())
                case .failure(let failure):
                    self.view?.error(error: failure.localizedDescription)
                    self.router.showAlertWithTitle(failure.localizedDescription)
                }
            })
        }
    }
    
    //MARK: - Add user
    func addUserToEvent(idEvent: String, date: Date, time: String, isComplete: Bool, city: CityModel) {
        guard idEvent != "" else {
            router.showAlertWithTitle(DetailPresenterConstants.selectEvent)
            return
        }
        
        guard let idUser = firebase.currentUserId, let currentCity = storage?.currentCity else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }
        
        guard currentCity == city else {
            router.showAlertWithTitle(DetailPresenterConstants.differentCity)
            return
        }
        
        if let users = users, users.contains(where: { $0.id == idUser }) {
            router.showAlertWithTitle(DetailPresenterConstants.alreadyParticipating)
            return
        }
        
        network.hasEventOnSameDay(userId: idUser, date: date, excludingEventId: idEvent) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let hasConflict):
                guard !hasConflict else {
                    self.router.showAlertWithTitle(DetailPresenterConstants.alreadyHasEventThisDay)
                    return
                }
                self.proceedWithJoining(idEvent: idEvent, idUser: idUser, date: date, time: time, isComplete: isComplete)
            case .failure(let error):
                self.router.showAlertWithTitle(error.localizedDescription)
            }
        }
    }
    
    private func proceedWithJoining(idEvent: String, idUser: String, date: Date, time: String, isComplete: Bool) {
        network.writeUserToEvent(idEvent: idEvent, idUser: idUser) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                notification.createNotification(
                    identifier: idEvent,
                    title: DetailPresenterConstants.matchReminder,
                    body: "\(DetailPresenterConstants.eventTomorrowAt) \(" ") \(time)",
                    date: date
                )
                router.showAlertWithTitle(
                    isComplete ? DetailPresenterConstants.queueAdded : DetailPresenterConstants.userAdded
                )
            case .failure:
                router.showAlertWithTitle(DetailPresenterConstants.saveError)
            }
        }
    }
    
    //MARK: - Remove user
    func removeUserFromEvent(idEvent: String) {
        guard idEvent != "" else {
            router.showAlertWithTitle(DetailPresenterConstants.selectEvent)
            return
        }
        
        guard let idUser = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }
        
        guard let users = users, users.contains(where: { $0.id == idUser }) else {
            router.showAlertWithTitle(DetailPresenterConstants.notParticipating)
            return
        }
        
        network.removeUserFromEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                router.showAlertWithTitle(DetailPresenterConstants.unsubscribed)
                notification.cancelNotification(identifier: idEvent)
            case .failure(let error):
                router.showAlertWithTitle(DetailPresenterConstants.deleteError)
                view?.error(error: error.localizedDescription)
            }
        })
    }
    
    //MARK: - Fetch comments (without the ones from blocked users)
    func fetchComments(idEvent: String) {
        view?.load()

        var fetched: Result<[CommentModel], Error>?
        let group = DispatchGroup()

        group.enter()
        commentsManager.fetchComments(idEvent: idEvent) { result in
            fetched = result
            group.leave()
        }

        group.enter()
        loadBlockedUserIDs { group.leave() }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, let result = fetched else { return }
            self.view?.hideLoading()

            switch result {
            case .success(let comments):
                let visible = comments.filter { !self.blockedIDs.contains($0.userId) }
                self.comments = visible
                self.view?.successComments(comments: visible)
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }

    private func loadBlockedUserIDs(completion: @escaping () -> Void) {
        guard let myID = firebase.currentUserId else {
            completion()
            return
        }

        moderation?.fetchBlockedUserIDs(userId: myID) { [weak self] result in
            if case .success(let ids) = result {
                self?.blockedIDs = ids
            }
            completion()
        }
    }
    
    //MARK: - Update comments
    func updateComments(idEvent: String) {
        commentsManager.fetchComments(idEvent: idEvent) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoading()
            switch result {
            case .success(let comments):
                let visible = comments.filter { !self.blockedIDs.contains($0.userId) }
                self.comments = visible
                self.view?.updateComments(comments: visible)
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }

    //MARK: - Add comment
    func addComment(idEvent: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard ContentFilter.isAllowed(trimmed) else {
            router.showAlertWithTitle(ContentFilterStrings.rejected)
            return
        }
        
        guard let idUser = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }
        
        network.fetchUser(idUser: idUser) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let newComment = CommentModel(
                    id: "",
                    userId: idUser,
                    userName: user.name,
                    userImage: user.image,
                    text: trimmed,
                    date: Date()
                )
                self.commentsManager.addComment(idEvent: idEvent, comment: newComment) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let comment):
                        var updated = self.comments ?? []
                        updated.append(comment)
                        self.comments = updated
                        self.view?.successComments(comments: updated)
                    case .failure(let error):
                        self.view?.error(error: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Remove comment
    func removeComment(idEvent: String, comment: CommentModel) {
        guard firebase.currentUserId != nil else {
            router.showAlertWithTitle(EventsPresenterStrings.needToLogIn)
            return
        }
        
        guard canDeleteComment(comment) else {
            router.showAlertWithTitle(EventsPresenterStrings.cannotDeleteNotOwned)
            return
        }
        
        let commentId = comment.id
        
        commentsManager.deleteComment(idEvent: idEvent, commentId: commentId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let updated = (self.comments ?? []).filter { $0.id != commentId }
                self.comments = updated
                self.view?.successComments(comments: updated)
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }
    
    func canDeleteComment(_ comment: CommentModel) -> Bool {
        guard let currentUserId = firebase.currentUserId else { return false }
        let isOrganizer = org?.id == currentUserId
        let isCommentAuthor = comment.userId == currentUserId
        return isOrganizer || isCommentAuthor
    }
    
    func shareEvent(eventID: String) {
        let shareURL = "dvor://openScreen?screen=detail&eventId="
        let fullURL = shareURL + eventID
        view?.load()
        router.showShareSheet(items: [fullURL]) { [weak self] completed in
            guard let self = self else { return }
            self.view?.hideLoading()
        }
    }
    
    //MARK: - Report a comment
    func canReportComment(_ comment: CommentModel) -> Bool {
        guard let myID = firebase.currentUserId else { return false }
        return comment.userId != myID
    }

    func reportComment(idEvent: String, comment: CommentModel) {
        guard let myID = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }

        router.showReportReasons { [weak self] reason in
            guard let self = self else { return }

            let report = ReportModel(reporterId: myID,
                                     targetType: .comment,
                                     targetId: comment.id,
                                     reportedUserId: comment.userId,
                                     eventId: idEvent,
                                     reason: reason,
                                     contentText: comment.text)

            self.moderation?.report(report) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.router.showAlertWithTitle(ModerationStrings.reportSent)
                case .failure(let error):
                    self.router.showAlertWithTitle(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Block the author of a comment
    func blockCommentAuthor(_ comment: CommentModel) {
        confirmAndBlock(userId: comment.userId)
    }
    
    //MARK: - Block a user (shared by comments and the participants menu)
    private func confirmAndBlock(userId: String) {
        guard let myID = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }

        router.showAlertConfigur(title: ModerationStrings.blockTitle,
                                 message: ModerationStrings.blockMessage,
                                 titleActionButton: ModerationStrings.blockAction,
                                 handelr: { [weak self] in
            guard let self = self else { return }

            self.moderation?.blockUser(blockerId: myID, blockedId: userId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.blockedIDs.insert(userId)

                    let visibleComments = (self.comments ?? []).filter { $0.userId != userId }
                    self.comments = visibleComments
                    self.view?.successComments(comments: visibleComments)

                    let visibleUsers = (self.users ?? []).filter { $0.id != userId }
                    self.users = visibleUsers
                    self.view?.success(users: visibleUsers, org: self.org ?? OrganizatorModel())
                case .failure(let error):
                    self.router.showAlertWithTitle(error.localizedDescription)
                }
            }
        })
    }

    //MARK: - Send a report
    private func submit(_ report: ReportModel) {
        moderation?.report(report) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.router.showAlertWithTitle(ModerationStrings.reportSent)
            case .failure(let error):
                self.router.showAlertWithTitle(error.localizedDescription)
            }
        }
    }

    //MARK: - Report a user
    private func reportUser(_ user: UserModel) {
        guard let myID = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }

        router.showReportReasons { [weak self] reason in
            guard let self = self else { return }

            let report = ReportModel(reporterId: myID,
                                     targetType: .user,
                                     targetId: user.id,
                                     reportedUserId: user.id,
                                     eventId: nil,
                                     reason: reason,
                                     contentText: user.name)
            self.submit(report)
        }
    }

    //MARK: - Report an event
    func canReportEvent(orgId: String) -> Bool {
        return orgId != firebase.currentUserId
    }

    func reportEvent(eventId: String, eventName: String, orgId: String) {
        guard let myID = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }

        router.showReportReasons { [weak self] reason in
            guard let self = self else { return }

            let report = ReportModel(reporterId: myID,
                                     targetType: .event,
                                     targetId: eventId,
                                     reportedUserId: orgId,
                                     eventId: eventId,
                                     reason: reason,
                                     contentText: eventName)
            self.submit(report)
        }
    }
    
    func showBottomAlertForUser(model: UserModel) {
        let myID = firebase.currentUserId
        let isAnotherUser = myID != nil && model.id != myID

        router.showBottomSheetAlertForUser(
            model: model,
            onReport: isAnotherUser ? { [weak self] in self?.reportUser(model) } : nil,
            onBlock: isAnotherUser ? { [weak self] in self?.confirmAndBlock(userId: model.id) } : nil
        )
    }
    
    func showLocationOnMap(location: String) {
        router.showLocationOnMap(location: location)
    }
    
    func showDetailOrgInfo(model: OrganizatorModel) {
        router.pushDetailOrgInfo(model: model)
    }
    
    func popVC() {
        router.popVC()
    }
    
    deinit {
        AppLogger.log(#function, self)
    }
}
