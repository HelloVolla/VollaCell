package network.beechat.app.kaonic.services

import androidx.compose.runtime.mutableStateMapOf
import com.fasterxml.jackson.databind.ObjectMapper
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.launch
import network.beechat.kaonic.models.KaonicEvent
import network.beechat.kaonic.models.KaonicEventType
import network.beechat.kaonic.models.messages.ChatCreateEvent
import network.beechat.kaonic.models.messages.MessageEvent
import network.beechat.kaonic.models.messages.MessageFileEvent
import network.beechat.kaonic.models.messages.MessageTextEvent

class ChatService(scope: CoroutineScope) {
    /**
     * key is address of chat id
     */
    private val messages =
        mutableStateMapOf<String, MutableStateFlow<ArrayList<KaonicEvent<MessageEvent>>>>()

    /**
     * key is contact address,
     * value is chatUUID
     */
    private val contactChats = mutableStateMapOf<String, String>()


    private val objectMapper: ObjectMapper = ObjectMapper()

    init {
        scope.launch {
            KaonicService.events
                .filter { event -> KaonicEventType.messageEvents.contains(event.type) }
                .collect { event ->
                    when (event.data) {
                        is MessageTextEvent -> handleTextMessageEvent(
                            (event.data as MessageTextEvent).chatId,
                            event as KaonicEvent<MessageEvent>
                        )

                        is MessageFileEvent -> handleTextMessageEvent(
                            (event.data as MessageFileEvent).chatId,
                            event as KaonicEvent<MessageEvent>
                        )

                        is ChatCreateEvent ->
                            putOrUpdateChatId(
                                (event.data as ChatCreateEvent).chatId,
                                (event.data as ChatCreateEvent).address,
                            )
                    }
                }
        }
    }

    fun createChatWithAddress(address: String): String {
        if (!contactChats.containsKey(address)) {
            val chatId = java.util.UUID.randomUUID().toString()
            contactChats[address] = chatId
            KaonicService.createChat(address, chatId)
        }

        return contactChats[address]!!
    }

    fun getChatMessages(chatId: String): String {
        val chatMessages = messages.getOrPut(chatId) { MutableStateFlow(arrayListOf()) }
        return  objectMapper.writeValueAsString(chatMessages)
    }

    private fun handleTextMessageEvent(chatId: String, event: KaonicEvent<MessageEvent>) {
        val flow = messages.getOrPut(chatId) { MutableStateFlow(arrayListOf()) }
        val oldList = flow.value
        val existingMessages = oldList.filter {
            it.data is MessageEvent && (it.data as MessageEvent).id == event.data.id
        }
        if (existingMessages.isNotEmpty()) {
            val newList = ArrayList(oldList)
            val index = newList.indexOf(existingMessages.first())
            if (index != -1) {
                newList.removeAt(index)
                newList.add(index, event)
            }
            flow.value = newList
        } else {
            val newList = ArrayList(oldList)
            newList.add(event)
            flow.value = newList
        }
    }

    fun sendTextMessage(message: String, address: String) {
        KaonicService.sendTextMessage(message, address, contactChats[address]!!)
    }

    fun sendFileMessage(filePath: String, address: String) {
        KaonicService.sendFileMessage(filePath, address, contactChats[address]!!)

    }

    private fun putOrUpdateChatId(chatId: String, address: String) {
        contactChats[address] = chatId
    }
}